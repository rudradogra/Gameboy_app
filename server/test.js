const express = require('express');
const request = require('supertest');

// Simple test to verify server setup
async function testServer() {
  console.log('🧪 Testing GameBoy Dating App Server...\n');
  
  try {
    // Import and start the server
    const app = require('./server');
    
    // Test health endpoint
    const healthResponse = await request(app)
      .get('/health')
      .expect(200);
    
    console.log('✅ Health check passed');
    console.log('📋 Server Info:', healthResponse.body);
    
    console.log('\n🎮 GameBoy Dating App Server is ready!');
    console.log('📖 Next steps:');
    console.log('   1. Fill in your Supabase credentials in .env');
    console.log('   2. Set up the database schema (see README.md)');
    console.log('   3. Run: npm run dev');
    
  } catch (error) {
    console.error('❌ Server test failed:', error.message);
  }
}

if (require.main === module) {
  testServer();
}

module.exports = testServer;
