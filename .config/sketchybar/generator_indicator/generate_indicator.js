const sharp = require('sharp');
const fs = require('fs/promises');

// --- Configuration --
const configuration = [
  {
    name: "mauve",
    color: '#cba6f7',
  },
  {
    name: "red",
    color: '#f38ba8'
  },
  {
    name: "yellow",
    color: '#f9e2af'
  },
  {
    name: "green",
    color: '#a6e3a1'
  }
];
const BACKGROUND_COLOR = '#423B38';
const SIZE = 33;

// --- Constants definition --
const STROKE_WIDTH = 3;
const TOTAL_ARC_DEGREES = 270;
const START_ANGLE_DEG = 135;

// Constants for SVG path calculation
const RADIUS = (SIZE - STROKE_WIDTH) / 2;
const CENTER = SIZE / 2;

// Function to get the X/Y coordinates for a given angle on the circle
const getCoordinates = (angleInDegrees) => {
  const angleInRadians = (angleInDegrees * Math.PI) / 180;
  // Standard polar to cartesian conversion
  const x = CENTER + RADIUS * Math.cos(angleInRadians);
  const y = CENTER + RADIUS * Math.sin(angleInRadians);
  return { x, y };
};

// --- Main Generation Function ---
async function generateIndicators(count, conf) {
  // Use conf.name to create color-specific directories
  const ASSETS_DIR = `../assets/${conf.name}`;
  // Removed the '..' for cleaner directory structure relative to script

  await fs.mkdir(ASSETS_DIR, { recursive: true });
  console.log(`\n\n🎯 Processing Configuration: ${conf.name} (${conf.color})`);
  console.log(`✅ Directory '${ASSETS_DIR}' ensured.`);

  for (let i = 0; i <= count; i++) {
    // Calculate the sweep angle (0 to 270 degrees)
    const currentSweepAngle = Math.round((i * TOTAL_ARC_DEGREES) / 100);
    const currentEndAngle = START_ANGLE_DEG + currentSweepAngle;

    // Calculate arc coordinates
    const start = getCoordinates(START_ANGLE_DEG);
    const endFull = getCoordinates(START_ANGLE_DEG + TOTAL_ARC_DEGREES);
    const endIndicator = getCoordinates(currentEndAngle);

    // Arc flags: large-arc-flag (1 if angle > 180), sweep-flag (1 for clockwise)
    const largeArcFull = TOTAL_ARC_DEGREES > 180 ? 1 : 0;
    const largeArcIndicator = currentSweepAngle > 180 ? 1 : 0;

    const svgContent = `
            <svg width="${SIZE}" height="${SIZE}" viewBox="0 0 ${SIZE} ${SIZE}" xmlns="http://www.w3.org/2000/svg">
                <path
                    d="M ${start.x} ${start.y} 
                       A ${RADIUS} ${RADIUS} 0 ${largeArcFull} 1 ${endFull.x} ${endFull.y}"
                    fill="none"
                    stroke="${BACKGROUND_COLOR}"
                    stroke-width="${STROKE_WIDTH}"
                    stroke-linecap="round"
                />
                <path
                    d="M ${start.x} ${start.y} 
                       A ${RADIUS} ${RADIUS} 0 ${largeArcIndicator} 1 ${endIndicator.x} ${endIndicator.y}"
                    fill="none"
                    stroke="${conf.color}"
                    stroke-width="${STROKE_WIDTH}"
                    stroke-linecap="round"
                />
            </svg>`;

    const OUTPUT_FILE = `${ASSETS_DIR}/${i}.png`;

    await sharp(Buffer.from(svgContent))
      .png()
      .toFile(OUTPUT_FILE);

    if (i % 10 === 0 || i === count) {
      process.stdout.write(`...Generated ${i}/${count}\r`);
    }
  }

  console.log(`\n--- Finished Generating ${count} Indicators for ${conf.name} ---`);
}

// --- Initialization Wrapper to run the loops synchronously ---
async function init() {
  console.log("--- Starting Batch Generation ---");
  for (const conf of configuration) {
    await generateIndicators(100, conf).catch(err => {
      console.error(`🚨 ERROR generating for ${conf.name}:`, err.message);
    });
  }
  console.log("\n--- Batch Generation Complete ---");
}

init().catch(err => {
  console.error("🚨 CRITICAL ERROR:", err.message);
  process.exit(1);
});
