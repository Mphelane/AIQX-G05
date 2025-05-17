// index.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

// Basic route
app.get('/', (req, res) => {
  res.send('<div style="text-align:center; font-size: 24pt;html, body: height: 100%;margin: 0;">Tshepo Mphelane - AIQX Technical Assessment</div>');
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
