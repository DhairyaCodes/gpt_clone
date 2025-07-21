const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB connected successfully!"))
  .catch(err => console.error("❌ MongoDB connection error:", err));

app.get('/', (req, res) => {
  res.status(200).json({ message: "👋 Hello from the Gemini Clone Backend! Server is running." });
});

const chatRoutes = require('./routes/chatRoutes');
const historyRoutes = require('./routes/historyRoutes');

app.use('/api/chat', chatRoutes);
app.use('/api/conversations', historyRoutes);

app.listen(PORT, () => {
  console.log(`🚀 Server is listening on http://localhost:${PORT}`);
});