Table t;

float cx, cy;
float innerR = 120;
float maxR;

String[] apps;
int[] appCol;
float maxAppMin = 1;

void setup() {
  size(1100, 900);
  smooth(8);

  cx = width * 0.60;
  cy = height * 0.52;
  maxR = min(width, height) * 0.42;

t = loadTable("data/usage.csv", "header");
  if (t == null || t.getRowCount() == 0) exit();

  apps = getAppColumns(t);
  appCol = new int[apps.length];
  for (int i = 0; i < apps.length; i++) appCol[i] = colorFromName(apps[i]);

  for (TableRow r : t.rows()) {
    for (int k = 0; k < apps.length; k++) {
      maxAppMin = max(maxAppMin, r.getFloat(apps[k]));
    }
  }
}

void draw() {
  background(245);
  drawPetals();
  drawLegend();
  drawTitle();
}

void drawPetals() {
  pushMatrix();
  translate(cx, cy);

  noFill();
  stroke(220);
  strokeWeight(1);
  ellipse(0, 0, innerR * 2, innerR * 2);
  ellipse(0, 0, maxR * 2, maxR * 2);

  int n = t.getRowCount();
  float dayW = TWO_PI / max(1, n);
  float startA = -HALF_PI;

  for (int i = 0; i < n; i++) {
    TableRow r = t.getRow(i);

    float a0 = startA + i * dayW;
    float a1 = a0 + dayW;
    float pad = dayW * 0.04;

    float slice0 = a0 + pad;
    float slice1 = a1 - pad;

    float sliceW = slice1 - slice0;
    float subW = sliceW / max(1, apps.length);

    for (int k = 0; k < apps.length; k++) {
      float v = r.getFloat(apps[k]);
      if (v <= 0) continue;

      float b0 = slice0 + k * subW;
      float b1 = b0 + subW * 0.98;
      float bc = (b0 + b1) * 0.5;

      float h = map(v, 0, maxAppMin, 0, (maxR - innerR));
      float tipR = innerR + h;
      if (tipR > maxR) tipR = maxR;

      PVector A = polar(innerR, b0);
      PVector B = polar(innerR, b1);
      PVector T = polar(tipR, bc);

      noStroke();
      fill(appCol[k], 220);
      beginShape();
      vertex(A.x, A.y);
      vertex(B.x, B.y);
      vertex(T.x, T.y);
      endShape(CLOSE);
    }

    float mid = (slice0 + slice1) * 0.5;
    float labelR = innerR - 16;
    PVector L = polar(labelR, mid);

    fill(40);
    textAlign(CENTER, CENTER);
    textSize(9);
    String d = r.getString("date");
    text(d.substring(5), L.x, L.y);
  }

  popMatrix();
}

void drawLegend() {
  float x = 40;
  float y = 80;

  fill(30);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Apps", x, 30);

  textSize(12);
  for (int i = 0; i < apps.length; i++) {
    noStroke();
    fill(appCol[i]);
    rect(x, y + i * 22, 14, 14, 3);
    fill(30);
    text(apps[i], x + 22, y + i * 22 - 1);
  }

  fill(70);
  textSize(11);
  text("Each date is a slice.\nEach app is a triangle.\nTriangle height = minutes.", x, y + apps.length * 22 + 18);
}

void drawTitle() {
  fill(25);
  textAlign(CENTER, TOP);
  textSize(35);
  text("Dialy App Usage ", cx, 50);
}

String[] getAppColumns(Table tab) {
  ArrayList<String> cols = new ArrayList<String>();
  for (int i = 0; i < tab.getColumnCount(); i++) {
    String name = tab.getColumnTitle(i);
    if (name == null) continue;
    if (name.equals("date")) continue;
    if (name.equals("total_min")) continue;
    if (name.equals("peak_hour")) continue;
    if (name.startsWith("h")) continue;
    cols.add(name);
  }
  String[] out = new String[cols.size()];
  for (int i = 0; i < cols.size(); i++) out[i] = cols.get(i);
  return out;
}

PVector polar(float r, float a) {
  return new PVector(cos(a) * r, sin(a) * r);
}

int colorFromName(String s) {
  int h = 0;
  for (int i = 0; i < s.length(); i++) h = (h * 33 + s.charAt(i)) & 0x7fffffff;
  float r = 70 + (h % 180);
  float g = 70 + ((h / 7) % 180);
  float b = 70 + ((h / 49) % 180);
  return color(r, g, b);
}
