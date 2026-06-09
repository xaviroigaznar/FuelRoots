module Engine {
    using Toybox.Math;

    class FuelEngine {

        // =========================
        // ATHLETE PROFILE
        // =========================
        var ftp;
        var weight;

        // =========================
        // KJ
        // =========================
        var totalKj = 0.0;
        var lapKj = 0.0;

        // =========================
        // NORMALIZED POWER
        // =========================
        var powerBuffer = [];
        var bufferSize = 30;

        var rollingSum = 0.0;
        var npSum = 0.0;
        var npCount = 0;

        // =========================
        // CARBS BURNED
        // =========================
        var totalCarbsBurned = 0.0;
        var lapCarbsBurned = 0;
        var carbsBurnedSinceLastFuel = 0.0;

        // =====================================
        // TIME
        // =====================================
        var lastElapsedTime = 0;

        // =========================
        // INIT
        // =========================
        function initialize(profile) {
            ftp = profile.ftp;
            weight = profile.weight;
        }

        // =========================
        // MAIN UPDATE
        // =========================
        function update(state) {

            var elapsed =
                state.elapsedTime;

            var power =
                state.currentPower;

            // First update
            if (lastElapsedTime == 0) {

                lastElapsedTime = elapsed;
                return;
            }

            var deltaSeconds =
                (elapsed - lastElapsedTime)
                / 1000.0;

            // =================================
            // POWER ANALYTICS
            // =================================

            updateNP(power);

            // =================================
            // RELATIVE INTENSITY
            // =================================

            var ri =
                getIF();

            state.relativeIntensity = ri;

            // =================================
            // ENERGY
            // =================================

            updateEnergy(
                power,
                deltaSeconds
            );

            // =================================
            // CARBS
            // =================================

            updateCarbs(
                ri,
                deltaSeconds
            );

            // =================================
            // EXPORT TO STATE
            // =================================

            state.sessionCarbsBurned =
                totalCarbsBurned;

            state.lapCarbsBurned =
                lapCarbsBurned;

            state.carbBurnRate =
                calculateCarbBurnRate(ri);

            lastElapsedTime =
                elapsed;
        }

        // =====================================
        // ENERGY
        // =====================================
        function updateEnergy(
            power,
            deltaSeconds
        ) {

            if (power == null) {
                return;
            }

            var kjIncrement =
                (power * deltaSeconds)
                / 1000.0;

            totalKj += kjIncrement;
            lapKj += kjIncrement;
        }

        // =====================================
        // CARBS
        // =====================================

        function updateCarbs(
            relativeIntensity,
            deltaSeconds
        ) {

            var burnRate =
                calculateCarbBurnRate(
                    relativeIntensity
                );

            // g/sec
            var carbIncrement =
                (burnRate / 3600.0)
                * deltaSeconds;

            totalCarbsBurned +=
                carbIncrement;
            
            carbsBurnedSinceLastFuel += carbIncrement;

            lapCarbsBurned +=
                carbIncrement;
        }

        // =====================================
        // CARB MODEL
        // =====================================

        function calculateCarbBurnRate(
            relativeIntensity
        ) {

            // Dynamic continuous model
            //
            // Easy ride:
            // ~30g/h
            //
            // Hard ride:
            // ~110g/h

            return
                20 +
                (relativeIntensity
                * weight
                * 1.2);
        }

        // =========================
        // NP
        // =========================
        function updateNP(power) {

            if (power == null) { return; }

            powerBuffer.add(power);
            rollingSum += power;

            if (powerBuffer.size() > bufferSize) {

                rollingSum -= powerBuffer[0];
                powerBuffer.remove(0);
            }

            if (powerBuffer.size() == bufferSize) {

                var avg30 = rollingSum / bufferSize;

                npSum += Math.pow(avg30, 4);
                npCount++;
            }
        }

        // =========================
        // GETTERS
        // =========================
        function getNP() {

            if (npCount == 0) { return 0; }

            return Math.pow(npSum / npCount, 0.25);
        }

        function getIF() {

            var np = getNP();

            if (ftp == 0) { return 0; }

            return np / ftp;
        }

        function getTotalKj() {
            return totalKj;
        }

        function getLapKj() {
            return lapKj;
        }

        function getTotalCarbsBurned() {
            return totalCarbsBurned;
        }

        function getLapCarbsBurned() {
            return lapCarbsBurned;
        }

        function resetCarbsBurnedSinceLastFuel() {
            carbsBurnedSinceLastFuel = 0.0;
        }

        // =========================
        // EVENTS
        // =========================

        function onLap() {
            lapKj = 0;
            lapCarbsBurned = 0;
        }
    }
}