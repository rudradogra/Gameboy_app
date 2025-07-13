const sharp = require('sharp');
const path = require('path');
const fs = require('fs').promises;
const { supabase, supabaseAdmin } = require('../config/supabase');

class ImageProcessor {
  constructor() {
    this.bucketName = 'profile-images';
    this.outputDir = path.join(__dirname, '../uploads/processed');
    this.inputDir = path.join(__dirname, '../uploads/images');
  }

  async ensureDirectoryExists(dirPath) {
    try {
      await fs.access(dirPath);
    } catch {
      await fs.mkdir(dirPath, { recursive: true });
    }
  }

  async uploadToSupabase(buffer, filename, contentType = 'image/png') {
    try {
      console.log(`📤 Uploading ${filename} to Supabase storage...`);
      console.log(`📊 Buffer size: ${buffer.length} bytes`);
      console.log(`🏷️ Content type: ${contentType}`);
      
      const { data, error } = await supabaseAdmin.storage
        .from(this.bucketName)
        .upload(filename, buffer, {
          contentType,
          upsert: true // Allow overwriting existing files
        });

      if (error) {
        console.error('❌ Supabase upload error:', error);
        throw new Error(`Failed to upload to Supabase: ${error.message}`);
      }

      console.log(`✅ Successfully uploaded to Supabase: ${filename}`);
      console.log(`📁 Upload data:`, data);
      
      // Verify the file was uploaded by checking if it exists
      const fileExists = await this.verifySupabaseFile(filename);
      if (!fileExists) {
        console.error('❌ File not found after upload!');
        throw new Error('File upload verification failed');
      }
      
      const publicUrl = this.getSupabaseImageUrl(filename);
      console.log(`🌐 Public URL: ${publicUrl}`);
      
      return data;
    } catch (error) {
      console.error('💥 Supabase upload exception:', error);
      throw error;
    }
  }

  getSupabaseImageUrl(filename) {
    const { data: { publicUrl } } = supabase.storage
      .from(this.bucketName)
      .getPublicUrl(filename);
    
    console.log(`🔗 Generated public URL for ${filename}: ${publicUrl}`);
    return publicUrl;
  }

  async verifySupabaseFile(filename) {
    try {
      console.log(`🔍 Verifying file exists in Supabase: ${filename}`);
      
      const { data, error } = await supabaseAdmin.storage
        .from(this.bucketName)
        .list('', {
          search: filename
        });

      if (error) {
        console.error('❌ Error checking file:', error);
        return false;
      }

      const fileExists = data && data.some(file => file.name === filename);
      console.log(`📄 File ${filename} exists: ${fileExists}`);
      return fileExists;
    } catch (error) {
      console.error('💥 Error verifying file:', error);
      return false;
    }
  }

  async convertToRetro8Bit(inputPath, outputFilename, size = 200) {
    try {
      console.log(`🎨 Processing 8-bit retro image: ${outputFilename}`);
      
      // Create authentic 8-bit retro effect with enhanced pixelation and vibrant colors
      const processedBuffer = await sharp(inputPath)
        .resize(size, size, { 
          fit: 'cover',
          position: 'center'
        })
        // Enhance saturation for more vibrant RGB colors
        .modulate({
          saturation: 1.8, // Boost saturation for vivid retro colors
          brightness: 1.1  // Slight brightness increase
        })
        // Create heavy pixelation effect
        .resize(16, 16, { kernel: 'nearest' }) // Very small for chunky pixels
        .resize(size, size, { kernel: 'nearest' }) // Scale back up maintaining pixel blocks
        // Apply limited color palette for authentic retro look
        .png({
          palette: true,
          colors: 32, // Increased from 16 for better color variety but still retro
          dither: 0.3, // Reduced dither for cleaner pixel blocks
          compressionLevel: 0 // No compression to maintain sharp pixels
        })
        .toBuffer();

      // Upload to Supabase storage
      await this.uploadToSupabase(processedBuffer, outputFilename, 'image/png');
      
      console.log(`✅ 8-bit retro image processed and uploaded: ${outputFilename}`);
      return this.getSupabaseImageUrl(outputFilename);
    } catch (error) {
      console.error('❌ Error processing 8-bit retro image:', error);
      throw new Error(`8-bit retro processing failed: ${error.message}`);
    }
  }

  async convertToGameBoyStyle(inputPath, outputFilename) {
    // Use the same 8-bit processing for consistency
    return this.convertToRetro8Bit(inputPath, outputFilename, 160);
  }

  async convertToRetroPixelated(inputPath, outputFilename) {
    // Use the same 8-bit processing for consistency
    return this.convertToRetro8Bit(inputPath, outputFilename, 200);
  }

  async deleteFile(filePath) {
    try {
      await fs.unlink(filePath);
      console.log(`🗑️ Deleted local file: ${filePath}`);
    } catch (error) {
      console.warn(`⚠️ Could not delete local file ${filePath}: ${error.message}`);
    }
  }

  async deleteFromSupabase(filename) {
    try {
      console.log(`🗑️ Deleting from Supabase: ${filename}`);
      
      const { error } = await supabaseAdmin.storage
        .from(this.bucketName)
        .remove([filename]);

      if (error) {
        console.error('❌ Supabase delete error:', error);
        throw new Error(`Failed to delete from Supabase: ${error.message}`);
      }

      console.log(`✅ Successfully deleted from Supabase: ${filename}`);
    } catch (error) {
      console.error('💥 Supabase delete exception:', error);
      throw error;
    }
  }

  getProcessedImageUrl(filename) {
    // Return Supabase public URL for cloud storage
    return this.getSupabaseImageUrl(filename);
  }
}

module.exports = new ImageProcessor();
