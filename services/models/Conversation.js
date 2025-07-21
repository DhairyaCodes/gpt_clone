const mongoose = require('mongoose');

const messagePartSchema = new mongoose.Schema({
  text: { 
    type: String 
  },
  imageUrl: {
    type: String 
  },
}, { _id: false });

const messageSchema = new mongoose.Schema({
  role: {
    type: String,
    required: true,
    enum: ['user', 'model']
  },
  parts: [messagePartSchema],
  timestamp: {
    type: Date,
    default: Date.now
  }
}, { _id: false });

const conversationSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    index: true
  },
  title: {
    type: String,
    default: 'New Conversation'
  },
  modelUsed: {
    type: String,
    required: true
  },
  messages: [messageSchema],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Conversation = mongoose.model('Conversation', conversationSchema);

module.exports = Conversation;