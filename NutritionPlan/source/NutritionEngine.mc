using Toybox.Activity;
using Toybox.Math;
using Toybox.System;

class NutritionEngine {

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
    var glycogenCapacity = 400; // gramos aprox disponibles
    var estimatedBurnRate = 0.0;

    // =========================
    // HIDRATACIÓN
    // =========================
    var lastDrinkTime = 0;

    // =========================
    // INIT
    // =========================
    function initialize(ftpValue, weightValue) {

        ftp = ftpValue;
        weight = weightValue;
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

    function getEnergyDeficit(elapsedTime) {
        var expected = expectedDynamicCarbs(elapsedTime, estimateCarbBurnRate());
        return expected - consumedCarbs;
    }

    function getEnergyStatus(elapsedTime) {

        var deficit = getEnergyDeficit(elapsedTime);

        if (deficit < 30) { return "GREEN"; }
        else if (deficit < 60) { return "LOW"; }
        else { return "CRITICAL"; }
    }

    function predictBonkTime(elapsedTime) {
        var deficit = getEnergyDeficit(elapsedTime);
        var burnRate = estimateCarbBurnRate();
        var remaining = glycogenCapacity - deficit;

        if (remaining <= 0) { return 0; }
        else {
            // minutos restantes
            return (remaining / burnRate) * 60;
        }
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
    function expectedDynamicCarbs(elapsedTime, carbsPerHour) {
        return carbsPerHour * (elapsedTime / 3600000.0);
    }

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

    function deficitCarbs(elapsedTime) {

        return expectedCarbs(elapsedTime) - consumedCarbs;
    }

    function nextEatCountdown() {

        var threshold = 100;

        return threshold - (totalKj - lastEatKj);
    }

    function estimateCarbBurnRate() {

        var IF = getIF();

        // gramos por hora estimados

        if (IF < 0.60) { return 40; }
        if (IF < 0.70) { return 55; }
        if (IF < 0.80) { return 70; }
        if (IF < 0.90) { return 90; }

        return 110;
    }

    function shouldFuelNow(elapsedTime) {
        var status = getEnergyStatus(elapsedTime);

        if (status == "CRITICAL") { return true; }
        else {
            var bonk = predictBonkTime(elapsedTime);

            if (bonk < 20) { return true; }
            else { return false; }
        }
    }

    // =========================
    // HYDRATION
    // =========================
    function hydrationRate() {

        var IF = getIF();

        if (IF < 0.65) { return 500; }
        if (IF < 0.80) { return 600; }
        if (IF < 0.90) { return 750; }

        return 900;
    }

    function nextDrinkCountdown() {

        var now = System.getTimer();

        var interval = 600000;

        var IF = getIF();

        if (IF > 0.8) { interval = 420000; }
        if (IF > 0.9) { interval = 300000; }

        return (interval - (now - lastDrinkTime)) / 1000;
    }

    // =========================
    // EVENTS
    // =========================
    function onLap() {

        lapKj = 0;

        consumedCarbs += 25;

        lastEatKj = totalKj;
    }
}