module Session {

    class WorkoutState {

        // =========================
        // Base Metrics
        // =========================

        var elapsedTime;
        var calories;
        var currentPower;
        var heartRate;
        var temperature;

        // =========================
        // Fuel
        // =========================

        var glycogenRemaining;
        var carbBurnRate;

        // UI-ready fuel metrics
        var timeToDepletion;
        var fuelStateLabel;

        // =========================
        // Hydration
        // =========================

        var hydrationLoss;
        var sweatRate;

        // UI-ready hydration metrics
        var minutesUntilDrink;
        var hydrationDeficitMl;
        var hydrationStateLabel;
        var drinkCountdownLabel;

        // =========================
        // Prediction
        // =========================

        var fatiguePercent;
        var bonkRisk;

        // UI-ready status
        var statusLabel;

        function initialize() {

            // Base
            elapsedTime = 0;
            calories = 0;
            currentPower = 0;
            heartRate = 0;
            temperature = null;

            // Fuel
            glycogenRemaining = 100;
            carbBurnRate = 0;

            timeToDepletion = "--";
            fuelStateLabel = "Stable";

            // Hydration
            hydrationLoss = 0;
            sweatRate = 0;
            hydrationStateLabel = "STABLE";
            drinkCountdownLabel = "--";

            minutesUntilDrink = 0;
            hydrationDeficitMl = 0;

            // Prediction
            fatiguePercent = 0;
            bonkRisk = 0;

            statusLabel = "STABLE";
        }
    }
}