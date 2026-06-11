module Session {

    class WorkoutState {

        // =========================
        // Constants
        // =========================
        const CARBS_THRESHOLD = 30;
        const HYDRATION_THRESHOLD = 250;

        // =========================
        // Base Metrics
        // =========================

        var elapsedTime;
        var lapElapsedTime;
        var calories;
        var currentPower;
        var heartRate;
        var temperature;
        var rollingPower;
        var relativeIntensity;

        // =========================
        // Session Totals Metrics
        // =========================
        var sessionCarbsBurnedPerHour;
        var sessionCarbsIngestedPerHour;
        var sessionCarbsIngested;
        var sessionCarbsBurned;

        // =========================
        // Lap Metrics
        // =========================
        var lapCarbsBurnedPerHour;
        var lapCarbsIngestedPerHour;
        var lapCarbsIngested;
        var lapCarbsBurned;

        // =========================
        // Countdown Metrics
        // =========================
        var nextDrinkCountdownLabel;
        var hydrationDeficitLabel;

        var nextFuelCountdownLabel;
        var carbsDeficit;

        // =========================
        // Fuel
        // =========================
        var carbBurnRate;

        var minutesUntilFuel;

        // =========================
        // Hydration
        // =========================
        var sessionHydrationLoss;
        var sessionHydrationDrunk;
        var sessionHydrationDrunkPerHour;
        var lapHydrationLoss;
        var lapHydrationDrunk;
        var lapHydrationDrunkPerHour;
        var sweatRate;

        // UI-ready hydration metrics
        var minutesUntilDrink;
        var hydrationDeficitMl;
        var hydrationStateLabel;

        // =========================
        // Prediction
        // =========================

        var fatiguePercent;

        // UI-ready status
        var statusLabel;
        var bonkTimeLabel;
        var bonkRisk;

        // =========================
        // Alerts
        // =========================
        var activeAlert = Constants.AlertType.NONE;
        var alertText;
        var recommendedCarbs;
        var recommendedDrink;

        function initialize() {

            // Base
            elapsedTime = 0;
            lapElapsedTime = 0;
            calories = 0;
            currentPower = 0;
            heartRate = 0;
            temperature = null;
            rollingPower = 0;
            relativeIntensity = 0;

            // Fuel
            minutesUntilFuel = 0;

            sessionCarbsBurnedPerHour = "0g/h";
            sessionCarbsIngestedPerHour = "0g/h";
            sessionCarbsIngested = "0g";
            sessionCarbsBurned = 0.0;

            lapCarbsBurnedPerHour = "0g/h";
            lapCarbsIngestedPerHour = "0g/h";
            lapCarbsIngested = "0g";
            lapCarbsBurned = 0.0;
            nextFuelCountdownLabel = "--";
            carbsDeficit = 0;
            recommendedCarbs = 0;

            // Hydration
            sessionHydrationLoss = 0;
            sessionHydrationDrunk = 0;
            sessionHydrationDrunkPerHour = 0;
            lapHydrationLoss = 0;
            lapHydrationDrunk = 0;
            lapHydrationDrunkPerHour = 0;
            hydrationStateLabel = "STABLE";

            minutesUntilDrink = 0;
            hydrationDeficitMl = 0;
            recommendedDrink = 0;

            nextDrinkCountdownLabel = "--";
            hydrationDeficitLabel = "0ml";

            // Prediction
            fatiguePercent = 0;

            statusLabel = "STABLE";
            bonkTimeLabel = "--";
            bonkRisk = 0;
        }
    }
}