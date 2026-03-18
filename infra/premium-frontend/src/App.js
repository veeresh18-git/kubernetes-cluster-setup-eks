import React, { useState } from "react";
import { motion } from "framer-motion";

export default function App() {
  const [status, setStatus] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setStatus("Sending...");

    try {
      const res = await fetch("http://localhost:5000/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: e.target.name.value,
          email: e.target.email.value,
          message: e.target.message.value,
        }),
      });

      if (res.ok) {
        setStatus("✅ Inquiry sent successfully!");
        e.target.reset();
      } else {
        setStatus("❌ Failed to send");
      }
    } catch {
      setStatus("❌ Server error");
    }
  };

  return (
    <div className="bg-black text-white min-h-screen font-light">

      {/* Navbar */}
      <motion.div 
        initial={{ y: -40, opacity: 0 }} 
        animate={{ y: 0, opacity: 1 }} 
        className="flex justify-between items-center px-6 md:px-16 py-5 border-b border-gray-800 backdrop-blur-lg bg-black/40"
      >
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-gradient-to-br from-yellow-400 to-yellow-600 text-black flex items-center justify-center font-bold rounded">
            D
          </div>
          <div>
            <h1 className="text-lg font-semibold tracking-wide">
              Desired Decors & Interiors
            </h1>
            <p className="text-xs text-gray-400">
              Luxury Design Studio
            </p>
          </div>
        </div>

        <div className="space-x-6 hidden md:block text-gray-300">
          <a href="#projects" className="hover:text-yellow-400">Projects</a>
          <a href="#contact" className="hover:text-yellow-400">Contact</a>
        </div>
      </motion.div>

      {/* Hero */}
      <motion.div 
        initial={{ opacity: 0 }} 
        animate={{ opacity: 1 }} 
        transition={{ duration: 1 }}
        className="text-center py-32 px-6 relative"
      >
        <div className="absolute inset-0 bg-gradient-to-r from-yellow-500/10 to-transparent blur-3xl"></div>

        <h2 className="text-5xl md:text-7xl font-light leading-tight">
          Transforming Spaces into  
          <span className="block text-yellow-400 font-semibold mt-2">
            Luxury Experiences
          </span>
        </h2>

        <p className="text-gray-400 mt-6 max-w-xl mx-auto">
          Premium interiors crafted with elegance, precision, and modern aesthetics.
        </p>

        <motion.button 
          whileHover={{ scale: 1.1 }} 
          className="mt-10 px-8 py-3 bg-gradient-to-r from-yellow-400 to-yellow-600 text-black rounded-full font-medium shadow-lg"
        >
          Explore Projects
        </motion.button>
      </motion.div>

      {/* Projects */}
      <div id="projects" className="px-6 md:px-16 py-20">
        <h2 className="text-4xl font-semibold text-center mb-12 text-yellow-400">
          Our Projects
        </h2>

        <div className="grid md:grid-cols-3 gap-8">
          {[
            "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6",
            "https://images.unsplash.com/photo-1600585154340-be6161a56a0c",
            "https://images.unsplash.com/photo-1615874959474-d609969a20ed",
            "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c",
            "https://images.unsplash.com/photo-1616594039964-ae9021a400a0",
            "https://images.unsplash.com/photo-1600210492493-0946911123ea"
          ].map((img, i) => (
            <motion.div
              key={i}
              whileHover={{ scale: 1.05 }}
              className="overflow-hidden rounded-2xl border border-gray-800 backdrop-blur-lg"
            >
              <img
                src={img}
                alt="project"
                className="h-72 w-full object-cover hover:scale-110 transition duration-700"
              />
            </motion.div>
          ))}
        </div>
      </div>

      {/* Contact */}
      <div id="contact" className="px-6 md:px-16 py-24 bg-gradient-to-b from-black to-gray-900">
        <h2 className="text-4xl font-semibold text-center mb-12 text-yellow-400">
          Get in Touch
        </h2>

        <form onSubmit={handleSubmit} className="max-w-xl mx-auto space-y-5 backdrop-blur-lg bg-white/5 p-8 rounded-2xl border border-gray-800">
          <input name="name" placeholder="Your Name" className="w-full p-3 bg-black border border-gray-700 rounded" />
          <input name="email" placeholder="Your Email" className="w-full p-3 bg-black border border-gray-700 rounded" />
          <textarea name="message" placeholder="Your Requirement" className="w-full p-3 bg-black border border-gray-700 rounded" />

          <motion.button 
            whileHover={{ scale: 1.05 }} 
            className="w-full bg-gradient-to-r from-yellow-400 to-yellow-600 text-black py-3 font-semibold rounded"
          >
            Send Inquiry
          </motion.button>

          {status && (
            <p className="text-center text-green-400 mt-2">{status}</p>
          )}
        </form>
      </div>

      {/* Footer */}
      <div className="text-center py-6 text-gray-500 text-sm">
        © 2026 Desired Decors & Interiors
      </div>

      {/* WhatsApp */}
      <motion.a
        href="https://wa.me/918374329512"
        target="_blank"
        rel="noreferrer"
        whileHover={{ scale: 1.2 }}
        className="fixed bottom-6 right-6 bg-green-500 p-4 rounded-full shadow-lg"
      >
        💬
      </motion.a>

    </div>
  );
}