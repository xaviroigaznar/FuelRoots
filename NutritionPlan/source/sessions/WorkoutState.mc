module Session {
    class WorkoutState {

        // =========================
        // INPUTS (raw data)
        // =========================
        var elapsedTime;        // ms
        var calories;
        var currentPower;
        var temperature;

        // =========================
        // ATHLETE PROFILE (copied for convenience)
        // =========================
        var weight;
        var ftp;

        // =========================
        // DERIVED PERFORMANCE METRICS
        // =========================
        var np;
        var ifValue;            // evita usar "if" keyword
        var intensityFactor;

        // =========================
        // ENERGY MODEL
        // =========================
        var kjAccumulated;
        var carbConsumptionRate;     // g/h (derivado)
        var carbsConsumed;
        var carbsRequired;
        var carbDeficit;

        var glycogenEstimate;        // NO “remaining” absoluto, sino estimado

        // =========================
        // HYDRATION MODEL
        // =========================
        var sweatRate;               // ml/h
        var fluidLossTotal;
        var fluidIntake;
        var hydrationDeficit;
        var hydrationRate;
        var hydrationRisk;

        // =========================
        // FATIGUE MODEL
        // =========================
        var fatigueScore;            // 0–100 modelado
        var perceivedLoad;

        // =========================
        // PREDICTION OUTPUTS
        // =========================
        var bonkTimeEstimate;        // min
        var bonkRisk;                // LOW / MODERATE / HIGH / CRITICAL
        var fuelRecommendation;      // boolean
        var hydrationRecommendation;  // boolean

        function initialize() {

            elapsedTime = 0;
            calories = 0;
            currentPower = 0;
            temperature = null;

            np = 0;
            ifValue = 0;
            intensityFactor = 0;

            kjAccumulated = 0;
            carbConsumptionRate = 0;
            carbsConsumed = 0;
            carbsRequired = 0;
            carbDeficit = 0;
            glycogenEstimate = 400;

            sweatRate = 0;
            fluidLossTotal = 0;
            fluidIntake = 0;
            hydrationDeficit = 0;
            hydrationRate = 0;
            hydrationRisk = 0;

            fatigueScore = 0;
            perceivedLoad = 0;

            bonkTimeEstimate = 0;
            bonkRisk = "LOW";
            fuelRecommendation = false;
            hydrationRecommendation = false;
        }
    }
}