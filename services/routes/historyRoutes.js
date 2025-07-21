const express = require('express');
const Conversation = require('../models/Conversation.js');

const router = express.Router();

router.get('/models', (req, res) => {
  const models = [
    { name: 'Gemini Flash', code: 'gemini-1.5-flash-latest' },
    { name: 'Gemini Pro', code: 'gemini-1.5-pro-latest' }
  ];
  res.status(200).json(models);
});

router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const conversations = await Conversation.find({ userId: userId })
      .sort({ createdAt: -1 })
      .select('_id title createdAt modelUsed');

    res.status(200).json(conversations);
  } catch (error) {
    console.error("❌ Error fetching conversation list:", error);
    res.status(500).json({ error: 'Failed to fetch conversation list.' });
  }
});


router.get('/messages/:conversationId', async (req, res) => {
  try {
    const { conversationId } = req.params;
    
    const conversation = await Conversation.findById(conversationId);

    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found.' });
    }

    res.status(200).json(conversation);
  } catch (error) {
    console.error("❌ Error fetching conversation messages:", error);
    res.status(500).json({ error: 'Failed to fetch conversation messages.' });
  }
});

module.exports = router;