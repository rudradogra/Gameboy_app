require('dotenv').config();
const { supabaseAdmin } = require('./config/supabase');

async function setupDatabase() {
  console.log('🔧 Setting up GameBoy Dating App Database...\n');

  try {
    // Test connection
    const { data, count, error } = await supabaseAdmin
    .from('users')
    .select('*', { count: 'exact', head: true }); 

    if (error) {
        console.log('❌ Database connection failed:', error.message);
      console.log('📋 Database tables need to be created.');
      console.log('Please run the SQL commands from database_setup.sql in your Supabase dashboard:\n');
      console.log('1. Go to your Supabase dashboard');
      console.log('2. Open the SQL Editor');
      console.log('3. Copy and paste the contents of database_setup.sql');
      console.log('4. Run the SQL commands');
      console.log('5. Create a storage bucket named "profile-images" with public access\n');
      return;
    }

    console.log('✅ Database connection successful!');
    console.log('✅ Tables are accessible');
    console.log('\n🎮 Your GameBoy Dating App backend is ready!');
    console.log('\n📱 Next steps:');
    console.log('   1. Your Flutter app is now connected to the backend');
    console.log('   2. Test registration and login');
    console.log('   3. The app will store user data in Supabase');

  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    console.log('\n🔧 Please check:');
    console.log('   1. Your Supabase credentials in .env');
    console.log('   2. Run the database_setup.sql in Supabase dashboard');
    console.log('   3. Create the profile-images storage bucket');
  }
}

if (require.main === module) {
  setupDatabase().then(() => process.exit(0));
}

module.exports = setupDatabase;
