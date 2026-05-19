module Engine {
    using Toybox.Activity;
    using Toybox.Math;
    using Toybox.System;

    class FuelEngine {

        // =========================
        // CONFIG
        // =========================
        var ftp;
        var weight;

        // =========================
        // KJ
        // =========================
        var totalKj = 0.0;
        var lapKj = 0.0;
        var lastTime = 0;

        // =========================
        // NP
        // =========================
        var powerBuffer = [];
        var bufferSize = 30;

        var rollingSum = 0.0;
        var npSum = 0.0;
        var npCount = 0;

        // =========================
        // NUTRICIÓN
        // =========================
        var consumedCarbs = 0.0;
        var lastEatKj = 0;

        // =========================
        // INIT
        // =========================
        function initialize(profile) {
            ftp = profile.ftp;
            weight = profile.weight;
        }

        // =========================
        // UPDATE
        // =========================
        function update(info) {
            updateKj(info);
            updateNP(info.currentPower);
        }

        // =========================
        // KJ
        // =========================
        function updateKj(info) {
            if (lastTime == 0) {
                lastTime = info.elapsedTime;
                return;
            }

            var delta = (info.elapsedTime - lastTime) / 1000.0;

            if (info.currentPower != null) {

                var kjInc = (info.currentPower * delta) / 1000.0;

                totalKj += kjInc;
                lapKj += kjInc;
            }

            lastTime = info.elapsedTime;
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

        // =========================
        // CARBS
        // =========================
        function carbsPerHour() {

            var IF = getIF();

            if (IF < 0.65) { return 0.8 * weight; }
            if (IF < 0.80) { return 1.0 * weight; }
            if (IF < 0.90) { return 1.2 * weight; }

            return 1.4 * weight;
        }

        function expectedCarbs(elapsedTime) {

            return carbsPerHour() * (elapsedTime / 3600000.0);
        }

        function getConsumedCarbs() {
            return consumedCarbs;
        }

        function getDeficit(elapsedTime) {
            return expectedCarbs(elapsedTime)
                - consumedCarbs;
        }

        // =========================
        // EVENTS
        // =========================
        function registerFuel(intake) {
            consumedCarbs += intake;

            lastEatKj = totalKj;
        }

        function onLap() {
            lapKj = 0;
        }
    }
}