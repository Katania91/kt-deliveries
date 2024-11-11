# 📦 KT-Deliveries Script

<img src="https://i.ibb.co/mSnwdpT/up.png" alt="Cover" width="100%" />

A fully-featured FiveM delivery job script that offers a randomized package delivery system for players. Designed for flexibility and ease of customization, this script supports both **QBCore** and **ESX** frameworks and integrates with `ox_lib` for notifications, progress bars, and interaction targets.

## ✨ Features

- **📍 Randomized Delivery Locations**: Each delivery mission provides randomized delivery points from a predefined list in `config.lua`.
- **🚚 Realistic Delivery Job Experience**: Players interact with an NPC (Michael) to start and end their job, collect packages, and receive payments.
- **👕 Customizable Outfits**: Players change into specific uniforms for the job, with different configurations for male and female characters.
- **⏰ Penalized Late Deliveries**: Deliveries completed past the time limit receive reduced pay.
- **⚙️ Framework Compatibility**: Supports both **QBCore** and **ESX** frameworks.
- **🌐 Configurable Notifications and Translations**: All messages are localized, allowing easy customization for different languages.

## 📋 Requirements

- **Framework**: QBCore or ESX (specified in `config.lua`).
- **ox_lib**: Required for notifications, progress bars, and target interactions.
- **Emote Script**: Recommended to have an emote script like `rpemotes-reborn` to support the "box carrying" animation (`/e box`).

## 🚀 Installation

1. **Download and Install Dependencies**:
   - Ensure that `ox_lib` is installed and running on your server.
   - If you haven't, install an emote script like `rpemotes-reborn`.

2. **Clone or Download the Repository**:
   - Place the `kt-deliveries` folder in your `resources` directory.

3. **Configure the Script**:
   - Open `config.lua` to adjust settings to your preference.
   - Set your desired framework (`'qbcore'` or `'esx'`).
   - Define the server language (`'en'`, `'it'`, `'fr'`, etc.) and notification position.

4. **Add to Server Configuration**:
   - In your `server.cfg`, add:
     ```plaintext
     ensure kt-deliveries
     ```

## ⚙️ Configuration (`config.lua`)

### Framework and Locale
- **`Config.Framework`**: Set to `'qbcore'` or `'esx'`.
- **`Config.Locale`**: Set the language for notifications and labels (e.g., `'en'`, `'it'`, `'fr'`, etc.).

### NPC Configuration
- **`Config.MichaelCoords`**: Set the coordinates for the Michael NPC, who will serve as the delivery job handler.
- **`Config.MichaelModel`**: The model for Michael (default: `s_m_m_postal_02`).

### Delivery Vehicle Configuration
- **`Config.VanModel`**: The model of the delivery van (default: `boxville2`).
- **`Config.VanSpawnCoords`**: Coordinates for spawning the van.
- **`Config.VanSpawnHeading`**: Heading direction for the van.

### Delivery Job Settings
- **`Config.DeliveryLocations`**: List of possible delivery locations. The script randomly shuffles these locations for each job.
- **`Config.TotalPackages`**: Number of packages per job.
- **`Config.RewardMin` & `Config.RewardMax`**: Minimum and maximum cash reward per package.
- **`Config.MaxDeliveryTime`**: Time limit per delivery (in milliseconds).
- **`Config.ReducedPaymentPercentage`**: Percentage of reward if delivery is late.

### 👕 Outfits
- **`Config.Outfit.Male`** & **`Config.Outfit.Female`**: Customize the job outfits for male and female characters. Supports torso, legs, shoes, top, and arms components.

## 📖 Usage

1. **Start the Job**:
   - Go to Michael (location specified in `config.lua`) and interact with him to start the delivery job.
   - Michael will provide a uniform, and a delivery van will spawn nearby.

2. **Collect Packages**:
   - Approach the van and interact to pick up packages. A carrying animation will play while you hold the package.

3. **Make Deliveries**:
   - Follow the GPS route to each randomized delivery point.
   - At each location, deliver the package to the waiting NPC.

4. **Return to Michael**:
   - Once all deliveries are complete, the GPS will guide you back to Michael.
   - Return the van and end your shift to receive your payment.

## 🌐 Translations

The script supports multiple languages, which can be specified in `Config.Locale`. The available translations are:

- English (`en`)
- Italian (`it`)
- French (`fr`)
- German (`de`)
- Spanish (`es`)
- Portuguese (`pt`)

To add additional translations, create a new file in the `locales` folder following the same structure as the other locale files.

## 🛠️ Example Configuration

Here's an example of `config.lua` with common settings:

```lua
Config = {}

Config.Framework = 'qbcore'
Config.Locale = 'en'
Config.NotificationPosition = 'center-right'

Config.MichaelCoords = vector3(133.0, 96.30, 82.50) 
Config.MichaelHeading = 155.0
Config.MichaelModel = `s_m_m_postal_02`

Config.VanModel = `boxville2`
Config.VanSpawnCoords = vector3(116.0, 95.0, 81.0)
Config.VanSpawnHeading = 250.0

Config.DeliveryLocations = {
    vector3(318.255371, 562.251221, 154.539261),
    vector3(-17.561855, -296.779327, 45.757820),
    -- Add more delivery locations as needed
}

Config.TotalPackages = 10
Config.RewardMin = 100
Config.RewardMax = 125
Config.MaxDeliveryTime = 300000
Config.ReducedPaymentPercentage = 50

Config.Outfit = {
    Male = {
        torso = { component = 0, drawable = 241, texture = 0 },
        legs = { component = 0, drawable = 63, texture = 0 },
        shoes = { component = 0, drawable = 24, texture = 0 },
        top = { component = 0, drawable = 15, texture = 0 },
        arms = { component = 0, drawable = 0, texture = 0}
    },
    Female = {
        torso = { component = 0, drawable = 359, texture = 2 },
        legs = { component = 0, drawable = 129, texture = 0 },
        shoes = { component = 0, drawable = 24, texture = 0 },
        top = { component = 0, drawable = 15, texture = 0 },
        arms = { component = 0, drawable = 9, texture = 0}
    }
}
```

## 🔧 Commands and Interactions

- **Interact with Michael**: Start and end the delivery job by interacting with Michael.
- **Take Package**: Collect packages from the van by interacting with it.
- **Deliver Package**: Deliver packages to specified locations by interacting with NPCs.
- **Return GPS**: After completing deliveries, a GPS route guides the player back to Michael.

## 📜 License

This project is licensed under the MIT License.
