import express from "express";
import cors from "cors";
import mongoose from "mongoose";

const app = express();
app.use(cors());
app.use(express.json());

/* ---------------- DB CONNECT ---------------- */
mongoose.connect("mongodb://host.docker.internal:27017/interiors");

mongoose.connection.on("connected", () => {
  console.log("MongoDB connected ✅");
});

/* ---------------- SCHEMA ---------------- */
const LeadSchema = new mongoose.Schema({
  name: String,
  email: String,
  message: String,
}, { timestamps: true });

const Lead = mongoose.model("Lead", LeadSchema);

/* ---------------- API ---------------- */
app.post("/contact", async (req, res) => {
  try {
    const { name, email, message } = req.body;

    const newLead = await Lead.create({
      name,
      email,
      message
    });

    console.log("Saved:", newLead);

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: "Failed to save" });
  }
});

app.get("/leads", async (req, res) => {
  const leads = await Lead.find().sort({ createdAt: -1 });
  res.json(leads);
});

/* ---------------- SERVER ---------------- */
app.listen(5000, () => console.log("Server running on 5000"));