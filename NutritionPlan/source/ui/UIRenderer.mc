// ======================================================
// UIRenderer.mc
// ======================================================

module UI {

    using Toybox.Graphics;

    class UIRenderer {

        function initialize() {
        }

        // =====================================
        // SUMMARY BOX
        // =====================================

        function drawSummaryBox(
            dc,
            x,
            y,
            w,
            h,
            title,
            totalBurned,
            totalIntake,
            intakeRate,
            lapBurned,
            lapIntake,
            lapIntakeRate,
            accentColor
        ) {

            // =============================
            // BACKGROUND
            // =============================

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // BORDER
            // =============================

            dc.setColor(
                accentColor,
                Graphics.COLOR_BLACK
            );

            dc.drawRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // HEADER
            // =============================

            dc.fillRectangle(
                x,
                y,
                w,
                20
            );

            dc.setColor(
                Graphics.COLOR_WHITE,
                accentColor
            );

            dc.drawText(
                x + 6,
                y,
                Graphics.FONT_SMALL,
                title,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // =============================
            // CONTENT
            // =============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            // TOTAL SESSION TITLE
            dc.drawText(
                x + 6,
                y + 32,
                Graphics.FONT_SMALL,
                "TOTAL",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // Burn
            dc.drawText(
                x + 8,
                y + 54,
                Graphics.FONT_XTINY,
                "Burned: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 54,
                Graphics.FONT_SMALL,
                totalBurned,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Intake
            dc.drawText(
                x + 8,
                y + 76,
                Graphics.FONT_XTINY,
                "In: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 76,
                Graphics.FONT_SMALL,
                totalIntake,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            dc.drawText(
                x + 8,
                y + 98,
                Graphics.FONT_XTINY,
                "In rate: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 98,
                Graphics.FONT_SMALL,
                intakeRate,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // LAP SESSION TITLE
            dc.drawText(
                x + 6,
                y + 120,
                Graphics.FONT_SMALL,
                "LAP",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            // Burn
            dc.drawText(
                x + 8,
                y + 142,
                Graphics.FONT_XTINY,
                "Burned: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 142,
                Graphics.FONT_SMALL,
                lapBurned,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Intake
            dc.drawText(
                x + 8,
                y + 164,
                Graphics.FONT_XTINY,
                "In: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 164,
                Graphics.FONT_SMALL,
                lapIntake,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            dc.drawText(
                x + 8,
                y + 186,
                Graphics.FONT_XTINY,
                "In rate: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 186,
                Graphics.FONT_SMALL,
                lapIntakeRate,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
        }

        // =====================================
        // TELEMETRY BOX
        // =====================================

        function drawCountdownBox(
            dc,
            x,
            y,
            w,
            h,
            drinkCountdown,
            fuelCountdown
        ) {

            // =============================
            // BACKGROUND
            // =============================

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // BORDER
            // =============================

            dc.setColor(
                Graphics.COLOR_BLUE,
                Graphics.COLOR_BLACK
            );

            dc.drawRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // HEADER
            // =============================

            dc.fillRectangle(
                x,
                y,
                w,
                20
            );

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLUE
            );

            dc.drawText(
                x + 6,
                y,
                Graphics.FONT_SMALL,
                "NEXT INGESTION",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // =============================
            // CONTENT
            // =============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            // Drink countdown
            dc.drawText(
                x + 8,
                y + 32,
                Graphics.FONT_XTINY,
                "Drink in: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 32,
                Graphics.FONT_SMALL,
                drinkCountdown,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Fuel countdown
            dc.drawText(
                x + 8,
                y + 54,
                Graphics.FONT_XTINY,
                "Fuel in: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 54,
                Graphics.FONT_SMALL,
                fuelCountdown,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
        }

        // =====================================
        // STATUS BOX
        // =====================================

        function drawStatusBox(
            dc,
            x,
            y,
            w,
            h,
            status,
            fatigue,
            carbsDeficit,
            hydrationDeficit,
            bonkTime,
            risk
        ) {

            // =============================
            // BACKGROUND
            // =============================

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // BORDER
            // =============================

            var color =
                Graphics.COLOR_GREEN;

            if (status == "MODERATE") {

                color =
                    Graphics.COLOR_YELLOW;
            }

            if (status == "FATIGUED") {

                color =
                    Graphics.COLOR_ORANGE;
            }

            if (status == "CRITICAL") {

                color =
                    Graphics.COLOR_RED;
            }

            dc.setColor(
                color,
                Graphics.COLOR_BLACK
            );

            dc.drawRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // HEADER
            // =============================

            dc.fillRectangle(
                x,
                y,
                w,
                20
            );

            dc.setColor(
                Graphics.COLOR_WHITE,
                color
            );

            dc.drawText(
                x + 6,
                y,
                Graphics.FONT_SMALL,
                "STATUS",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // =============================
            // STATUS LABEL
            // =============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            dc.drawText(
                x + (w / 2),
                y + 40,
                Graphics.FONT_SMALL,
                status,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // =============================
            // FATIGUE
            // =============================

            dc.drawText(
                x + 8,
                y + 78,
                Graphics.FONT_XTINY,
                "Fatigue: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 78,
                Graphics.FONT_SMALL,
                fatigue,
                Graphics.TEXT_JUSTIFY_RIGHT
            );


            // =============================
            // CARBS DEFICIT
            // =============================

            dc.drawText(
                x + 8,
                y + 104,
                Graphics.FONT_XTINY,
                "Carbs deficit: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 104,
                Graphics.FONT_SMALL,
                carbsDeficit,
                Graphics.TEXT_JUSTIFY_RIGHT
            );


            // =============================
            // HYDRATION DEFICIT
            // =============================

            dc.drawText(
                x + 8,
                y + 128,
                Graphics.FONT_XTINY,
                "Hydration deficit: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 128,
                Graphics.FONT_SMALL,
                hydrationDeficit,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // =============================
            // BONK
            // =============================

            dc.drawText(
                x + 8,
                y + 152,
                Graphics.FONT_XTINY,
                "Bonk",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 152,
                Graphics.FONT_SMALL,
                bonkTime,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // =============================
            // RISK
            // =============================

            dc.drawText(
                x + 8,
                y + 176,
                Graphics.FONT_XTINY,
                "Risk",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 176,
                Graphics.FONT_SMALL,
                risk,
                Graphics.TEXT_JUSTIFY_RIGHT
            );
        }

        function drawMetricCard(
            dc,
            x,
            y,
            w,
            h,
            color,
            title,
            primaryValue,
            secondaryValue
        ) {

            // Background
            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillRectangle(x, y, w, h);

            // Border
            dc.setColor(
                color,
                Graphics.COLOR_BLACK
            );

            dc.drawRectangle(x, y, w, h);

            // Top header line
            dc.fillRectangle(x, y, w, 18);

            // Header text
            dc.setColor(
                Graphics.COLOR_WHITE,
                color
            );

            dc.drawText(
                x + 8,
                y + 2,
                Graphics.FONT_XTINY,
                title,
                Graphics.TEXT_JUSTIFY_LEFT
            );

            // Main value
            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            dc.drawText(
                x + (w / 2),
                y + (h / 2) - 12,
                Graphics.FONT_NUMBER_MEDIUM,
                primaryValue,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // Secondary value
            dc.drawText(
                x + (w / 2),
                y + (h / 2) + 50,
                Graphics.FONT_XTINY,
                secondaryValue,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // =====================================
        // ALERT OVERLAY
        // =====================================
        function drawAlertOverlay(
            dc,
            title,
            message,
            color
        ) {

            var width =
                dc.getWidth();

            var height =
                dc.getHeight();

            // =============================
            // OVERLAY SIZE
            // =============================

            var w = width - 30;
            var h = 90;

            var x = 15;
            var y = (height / 2) - (h / 2);

            // =============================
            // SHADOW
            // =============================

            dc.setColor(
                Graphics.COLOR_DK_GRAY,
                Graphics.COLOR_DK_GRAY
            );

            dc.fillRectangle(
                x + 3,
                y + 3,
                w,
                h
            );

            // =============================
            // MAIN BOX
            // =============================

            dc.setColor(
                Graphics.COLOR_BLACK,
                Graphics.COLOR_BLACK
            );

            dc.fillRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // BORDER
            // =============================

            dc.setColor(
                color,
                Graphics.COLOR_BLACK
            );

            dc.drawRectangle(
                x,
                y,
                w,
                h
            );

            // =============================
            // HEADER
            // =============================

            dc.fillRectangle(
                x,
                y,
                w,
                24
            );

            dc.setColor(
                Graphics.COLOR_WHITE,
                color
            );

            dc.drawText(
                x + (w / 2),
                y + 4,
                Graphics.FONT_SMALL,
                title,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // =============================
            // MESSAGE
            // =============================

            dc.setColor(
                Graphics.COLOR_WHITE,
                Graphics.COLOR_BLACK
            );

            dc.drawText(
                x + (w / 2),
                y + 38,
                Graphics.FONT_MEDIUM,
                message,
                Graphics.TEXT_JUSTIFY_CENTER
            );

            // =============================
            // FOOTER
            // =============================

            dc.drawText(
                x + (w / 2),
                y + 65,
                Graphics.FONT_XTINY,
                "PRESS START",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
}