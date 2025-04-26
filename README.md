# Rakshak

## Blood Donation Application

Rakshak is a comprehensive blood donation and requesting application built for the residents of Jaysingpur. The app connects blood donors with those in need, provides information about nearby blood banks, and gamifies the donation process through a leaderboard system.

## Features

- **Blood Donation & Request**: Simple process to donate blood or request blood in emergencies
- **Nearby Blood Banks**: Locate blood banks in your vicinity with integrated maps
- **Event Notifications**: Stay updated about upcoming blood donation camps and events
- **Donation Leaderboard**: Recognize frequent donors through a competitive leaderboard
- **User Profiles**: Manage your donation history and personal information

## Technologies Used

- **Frontend**: Flutter (Dart) for cross-platform mobile development
- **Backend**: Supabase for database, authentication, and storage
- **Mapping**: Google Maps integration for location services
- **Storage**: Hive for local storage

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/rakshak.git
   cd rakshak
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Database Setup

### Supabase Configuration

1. Create a Supabase account at [supabase.com](https://supabase.com)
2. Create a new project
3. Set up the following tables:

#### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  blood_group TEXT,
  phone TEXT,
  location TEXT,
  last_donation_date TIMESTAMP,
  donation_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Blood Requests Table
```sql
CREATE TABLE blood_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id UUID REFERENCES users(id),
  blood_group TEXT NOT NULL,
  quantity INTEGER,
  hospital TEXT,
  location TEXT,
  urgency TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Donations Table
```sql
CREATE TABLE donations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  donor_id UUID REFERENCES users(id),
  blood_group TEXT NOT NULL,
  quantity INTEGER,
  donation_date TIMESTAMP WITH TIME ZONE,
  hospital TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

4. Add your Supabase URL and anon key to the project:
    - Create a `.env` file in the project root
    - Add the following:
      ```
      SUPABASE_URL=your_supabase_url
      SUPABASE_ANON_KEY=your_supabase_anon_key
      ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.