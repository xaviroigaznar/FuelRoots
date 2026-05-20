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
            burnRate,
            intakeRate,
            totalIntake,
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

            // Burn
            dc.drawText(
                x + 8,
                y + 32,
                Graphics.FONT_XTINY,
                "Burn",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 32,
                Graphics.FONT_SMALL,
                burnRate.format("%.0f")
                + "g/h",
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Intake
            dc.drawText(
                x + 8,
                y + 54,
                Graphics.FONT_XTINY,
                "In",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 54,
                Graphics.FONT_SMALL,
                intakeRate.format("%.0f")
                + "g/h",
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Total
            dc.drawText(
                x + 8,
                y + 76,
                Graphics.FONT_XTINY,
                "Total",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 76,
                Graphics.FONT_SMALL,
                totalIntake.format("%.0f")
                + "g",
                Graphics.TEXT_JUSTIFY_RIGHT
            );
        }

        // =====================================
        // TELEMETRY BOX
        // =====================================

        function drawTelemetryBox(
            dc,
            x,
            y,
            w,
            h,
            drinkCountdown,
            hydrationDeficit,
            fuelCountdown,
            carbDeficit
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
                "FUEL / HYD",
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
                "Drink in:",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 32,
                Graphics.FONT_SMALL,
                drinkCountdown,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Hydration deficit
            dc.drawText(
                x + 8,
                y + 54,
                Graphics.FONT_XTINY,
                "Hydration deficit:",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 54,
                Graphics.FONT_SMALL,
                hydrationDeficit,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Fuel countdown
            dc.drawText(
                x + 8,
                y + 84,
                Graphics.FONT_XTINY,
                "Fuel in: ",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 84,
                Graphics.FONT_SMALL,
                fuelCountdown,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // Carb deficit
            dc.drawText(
                x + 8,
                y + 106,
                Graphics.FONT_XTINY,
                "Carbs deficit:",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 106,
                Graphics.FONT_SMALL,
                carbDeficit,
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
            // BONK
            // =============================

            dc.drawText(
                x + 8,
                y + 78,
                Graphics.FONT_XTINY,
                "Bonk",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 78,
                Graphics.FONT_SMALL,
                bonkTime,
                Graphics.TEXT_JUSTIFY_RIGHT
            );

            // =============================
            // RISK
            // =============================

            dc.drawText(
                x + 8,
                y + 104,
                Graphics.FONT_XTINY,
                "Risk",
                Graphics.TEXT_JUSTIFY_LEFT
            );

            dc.drawText(
                x + w - 8,
                y + 104,
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
    }
}