const express = require('express');
const { supabase, supabaseAdmin } = require('../config/supabase');
const router = express.Router();

// Debug endpoint to test bucket access
router.get('/test-bucket', async (req, res) => {
  try {
    console.log('🔍 Testing Supabase bucket access...');
    
    // Test 1: List buckets
    const { data: buckets, error: bucketsError } = await supabaseAdmin.storage.listBuckets();
    
    if (bucketsError) {
      console.error('❌ Error listing buckets:', bucketsError);
      return res.status(500).json({ 
        error: 'Failed to list buckets', 
        details: bucketsError 
      });
    }
    
    console.log('📦 Available buckets:', buckets.map(b => b.name));
    
    // Test 2: Check if profile-images bucket exists
    const profileImagesBucket = buckets.find(b => b.name === 'profile-images');
    
    if (!profileImagesBucket) {
      return res.status(404).json({ 
        error: 'profile-images bucket not found',
        availableBuckets: buckets.map(b => b.name)
      });
    }
    
    console.log('✅ profile-images bucket found:', profileImagesBucket);
    
    // Test 3: List files in the bucket
    const { data: files, error: filesError } = await supabaseAdmin.storage
      .from('profile-images')
      .list('', { limit: 10 });
      
    if (filesError) {
      console.error('❌ Error listing files:', filesError);
      return res.status(500).json({ 
        error: 'Failed to list files in bucket', 
        details: filesError 
      });
    }
    
    console.log(`📁 Found ${files.length} files in bucket`);
    
    // Test 4: Try to get public URL for a file (if any exist)
    let publicUrlTest = null;
    if (files.length > 0) {
      const testFile = files[0];
      const { data: { publicUrl } } = supabase.storage
        .from('profile-images')
        .getPublicUrl(testFile.name);
        
      publicUrlTest = {
        filename: testFile.name,
        publicUrl: publicUrl
      };
      
      console.log('🌐 Test public URL:', publicUrl);
    }
    
    // Test 5: Check bucket public policy
    const { data: policies, error: policiesError } = await supabaseAdmin.storage
      .from('profile-images')
      .list('', { search: '' });
    
    res.json({
      success: true,
      bucket: profileImagesBucket,
      fileCount: files.length,
      sampleFiles: files.slice(0, 3),
      publicUrlTest,
      message: 'Bucket access test completed'
    });
    
  } catch (error) {
    console.error('💥 Bucket test error:', error);
    res.status(500).json({ 
      error: 'Bucket test failed', 
      details: error.message 
    });
  }
});

// Test endpoint to check a specific file URL
router.get('/test-file-access/:filename', async (req, res) => {
  try {
    const { filename } = req.params;
    
    console.log(`🔍 Testing access to file: ${filename}`);
    
    // Get the public URL
    const { data: { publicUrl } } = supabase.storage
      .from('profile-images')
      .getPublicUrl(filename);
      
    console.log(`🌐 Public URL: ${publicUrl}`);
    
    // Try to fetch the file directly using Node.js fetch
    const fetch = require('node-fetch');
    
    try {
      const response = await fetch(publicUrl);
      
      res.json({
        filename,
        publicUrl,
        statusCode: response.status,
        statusText: response.statusText,
        headers: Object.fromEntries(response.headers.entries()),
        accessible: response.ok
      });
      
    } catch (fetchError) {
      res.json({
        filename,
        publicUrl,
        fetchError: fetchError.message,
        accessible: false
      });
    }
    
  } catch (error) {
    console.error('💥 File access test error:', error);
    res.status(500).json({ 
      error: 'File access test failed', 
      details: error.message 
    });
  }
});

// Fix bucket to be public
router.post('/fix-bucket-public', async (req, res) => {
  try {
    console.log('🔧 Attempting to make profile-images bucket public...');
    
    // First, let's try to update the bucket to be public
    const { data, error } = await supabaseAdmin.storage
      .updateBucket('profile-images', {
        public: true,
        fileSizeLimit: null,
        allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp']
      });

    if (error) {
      console.error('❌ Error updating bucket:', error);
      return res.status(500).json({ 
        error: 'Failed to update bucket', 
        details: error,
        suggestion: 'You may need to make the bucket public manually in the Supabase dashboard'
      });
    }

    console.log('✅ Bucket updated successfully:', data);
    
    // Test access again
    const { data: buckets } = await supabaseAdmin.storage.listBuckets();
    const updatedBucket = buckets.find(b => b.name === 'profile-images');
    
    res.json({
      success: true,
      message: 'Bucket updated to public successfully',
      bucket: updatedBucket
    });
    
  } catch (error) {
    console.error('💥 Fix bucket error:', error);
    res.status(500).json({ 
      error: 'Failed to fix bucket', 
      details: error.message,
      instructions: {
        manual_fix: 'Go to Supabase Dashboard > Storage > profile-images > Settings > Enable "Public bucket"',
        dashboard_url: 'https://supabase.com/dashboard/project/' + process.env.SUPABASE_URL?.split('//')[1]?.split('.')[0]
      }
    });
  }
});

module.exports = router;
