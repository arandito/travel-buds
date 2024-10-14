# Travel Buds <img src="https://antonioaranda.dev/images/travel-buds/icon.png" width="30" alt="App Icon">

Travel Buds is an iOS chat app that matches travellers with others based on location, activity interests, and trip dates.

<div align="center">
  <img src="https://antonioaranda.dev/images/travel-buds/ui.png" width="90%" alt="App Icon">
</div>

## Features

- Feature 1: Group matching algorithm to group users based on their trip parameters (location, dates, activity interests).
  - Users add trips by location (e.g. Paris), activity interest (night life, nature, etc.), and trip dates. When at least 3 users submit matching parameters, a new group chat is created for that trip.
- Feature 2: Real-time chat list and chat interface.
  - Users are able to chat with other travelers to plan social gatherings and activities or talk about their trips.
- Feature 3: Activity recommendation system.
  - Users can search for activities in any location given an interest.

## Technologies Used

- SwiftUI
- Firebase (for backend and authentication)
- Google Cloud Platform (for backend cloud functions)

## Architecture

![App Screenshot](https://antonioaranda.dev/images/travel-buds/arch.png)

## Future Enhancements

- Update and improve UI
- Optimize chat interface
- Incorporate Google Places API for recommendation system

## Installation

1. Clone the repo
   ```sh
   git clone https://github.com/your_username/travel-buds.git
   ```
2. Open the `Travel Buds.xcodeproj` file in Xcode
3. Build and run the project on your iOS device or simulator

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
