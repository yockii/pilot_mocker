# pilot_mocker

[中文](README_ZH.md)

## Project Introduction

pilot_mocker is a Flutter-based emulator designed to simulate the DJI Pilot 2 application running on DJI remote controllers. It is primarily intended for developing third-party cloud platforms using the DJI Cloud API, allowing developers to debug and validate related features without purchasing expensive Enterprise Edition drones.

## Key Features

- Mimics the DJI Pilot 2 application's interface for a familiar user experience.
- Simulates the capabilities of DJI's djiBridge via JavaScript injection.
- Gradually implements full support for the DJI Cloud API.
- Cross-platform support on Windows, Android, and more.
- Directly opens Developer Tools (inspect) for convenient debugging and inspection.

## Usage

We recommend using and developing on Windows and running the pre-built binaries:

1. Launch the application. Click the “Welcome” card to enter the “Cloud Service” page, mirroring the real DJI Pilot 2 flow.
2. On the “Cloud Service” page, click the “Open Platform” card to access the “Third-Party Cloud” page.
3. In the “Third-Party Cloud” page, enter a URL or select one from history to connect.
4. After connecting, the app automatically loads the target page and injects the corresponding JavaScript scripts.

Enjoy the streamlined debugging and validation process!

