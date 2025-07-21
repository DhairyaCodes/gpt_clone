const express = require('express');
const mongoose = require('mongoose');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const axios = require('axios'); 

const Conversation = require('../models/Conversation.js');
const upload = require('../config/cloudinaryConfig.js'); 

const router = express.Router();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

async function urlToGoogleGenerativeAIPart(url, mimeType) {
  const response = await axios.get(url, { responseType: 'arraybuffer' });
  const base64Data = Buffer.from(response.data).toString('base64');
  return {
    inlineData: {
      data: base64Data,
      mimeType,
    },
  };
}

const generateTitle = async (message) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    const prompt = `Generate a short, concise title (3-4 words max) for the following user prompt. Respond with only the title and nothing else: "${message}"`;
    const result = await model.generateContent(prompt);
    const response = await result.response;
    return response.text().trim();
  } catch (error) {
    console.error("Error generating title:", error);
    return "New Conversation";
  }
};

router.post('/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image file uploaded.' });
  }
  
  // The 'upload' middleware handles everything. 
  // If we reach here, the file is already on Cloudinary.
  res.status(200).json({
    message: 'Image uploaded successfully!',
    imageUrl: req.file.path
  });
});

router.post('/', async (req, res) => {
  let { history, message, model, conversationId, imageUrl } = req.body;
  let fullResponseText = '';
  let finalConversationId = conversationId;

  try {
    if (!message || !model) {
      return res.status(400).json({ error: 'Missing required fields: message, model' });
    }
    history = history || [];

    if (conversationId === 'new') {
      finalConversationId = new mongoose.Types.ObjectId();
    }

    const geminiModel = genAI.getGenerativeModel({ model: model });
    const chat = geminiModel.startChat({ history });
    const promptParts = [{ text: message }];
    if (imageUrl) {
      const imagePart = await urlToGoogleGenerativeAIPart(imageUrl, 'image/jpeg');
      promptParts.push(imagePart);
    }

    const result = await chat.sendMessageStream(promptParts);
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.setHeader('Transfer-Encoding', 'chunked');

    if (conversationId === 'new') {
      res.setHeader('X-Conversation-Id', finalConversationId.toString());
    }

    for await (const chunk of result.stream) {
      const chunkText = chunk.text();
      fullResponseText += chunkText;
      res.write(chunkText);
    }
    res.end();

  } catch (error) {
    console.error("❌ Error in chat streaming:", error);
    res.status(500).json({ error: 'Failed to get response from Gemini' });
  } finally {
    if (fullResponseText) {
      const userMessage = { role: 'user', parts: [{ text: message, imageUrl: imageUrl }].filter(p => p.text || p.imageUrl) };
      const modelMessage = { role: 'model', parts: [{ text: fullResponseText }] };

      try {
        if (conversationId !== 'new') {
          await Conversation.findByIdAndUpdate(finalConversationId, {
            $push: { messages: { $each: [userMessage, modelMessage] } }
          });
        } else {
          const newConversation = new Conversation({
            _id: finalConversationId,
            userId: req.body.userId || "12345",
            title: await generateTitle(message),
            modelUsed: model,
            messages: [userMessage, modelMessage]
          });
          await newConversation.save();
        }
        console.log("✅ Conversation saved/updated successfully. ID:", finalConversationId);
      } catch (dbError) {
        console.error("❌ Error saving conversation to DB:", dbError);
      }
    }
  }
});


module.exports = router;