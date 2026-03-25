<div dir="rtl">

# ערכת ההתחלה של Claude Code

לבנות תוכנה עם AI. בלי לדעת לתכנת.

משכפלים את הריפו הזה, עוקבים אחרי ההוראות, ויוצאים עם סביבת Claude Code מוגדרת: זיכרון בין שיחות, סוכני AI מתמחים, כלי אוטומציה, ואם רוצים גם מערכת סוכנים אוטונומית שרצה 24/7 ושולטים בה מהטלפון.

**בחינם. קוד פתוח. בלי סדנאות.**

> **[English Guide](README.md)** | מדריך באנגלית

## מה צריך

### חומרה

| פריט | פרטים |
|------|-------|
| מחשב | Mac, Windows, או Linux. לפחות 16GB RAM. |
| טלפון (אופציונלי) | לשליטה מרחוק דרך Telegram. כל טלפון מתאים. |

### חשבונות ורישיונות

| פריט | עלות | הערות |
|------|------|-------|
| **Claude Code** | $20/חודש (Pro) או $100/חודש (Max) | שותף ה-AI שלכם. נרשמים ב-[claude.ai](https://claude.ai) |
| **חשבון GitHub** | חינם | לשכפול הריפו ולניהול פרויקטים. [github.com](https://github.com) |
| **OpenAI API Key** (אופציונלי) | ~$5-10/חודש | לתמלול קול (Whisper) ויצירת תמונות. [platform.openai.com](https://platform.openai.com) |
| **Google Cloud** (אופציונלי) | חינם | לחיבורי יומן ומייל. [console.cloud.google.com](https://console.cloud.google.com) |

### עלות חודשית

| רמת שימוש | עלות |
|-----------|------|
| בסיסי (Claude Pro בלבד) | ~$20/חודש |
| מלא (Claude Max + OpenAI + שרת) | ~$120/חודש |

## התקנה (10 דקות)

### Mac

```bash
# 1. שכפול
git clone https://github.com/Tokenized2027/Claude-Initilization-V7.git ~/Desktop/Claude
cd ~/Desktop/Claude

# 2. הרצת סקריפט התקנה (מתקין Homebrew, Node.js, Git, Claude Code CLI)
chmod +x setup-mac.sh && ./setup-mac.sh

# 3. הגדרת CLAUDE_HOME כדי שתוכלו לגשת לתיקייה מכל מקום
echo 'export CLAUDE_HOME="$HOME/Desktop/Claude"' >> ~/.zshrc && source ~/.zshrc

# 4. התקנת hooks + הגדרות (נותן ל-Claude זיכרון בין שיחות)
mkdir -p ~/.claude
cp dot-claude/settings.json ~/.claude/settings.json
chmod +x hooks/install-hooks.sh && ./hooks/install-hooks.sh

# 5. הגדרת זיכרון קבוע
mkdir -p ~/.claude/projects/-home-$(whoami)/memory
cp memory/MEMORY.md ~/.claude/projects/-home-$(whoami)/memory/MEMORY.md
```

### Windows

```powershell
# 1. התקנת דרישות מוקדמות (אם עוד לא מותקנים)
# Node.js v20+: https://nodejs.org
# Git: https://git-scm.com/download/win
# Claude Code CLI: npm install -g @anthropic-ai/claude-code

# 2. שכפול
git clone https://github.com/Tokenized2027/Claude-Initilization-V7.git %USERPROFILE%\Desktop\Claude
cd %USERPROFILE%\Desktop\Claude

# 3. העתקת הגדרות
mkdir %USERPROFILE%\.claude 2>nul
copy dot-claude\settings.json %USERPROFILE%\.claude\settings.json

# 4. הגדרת זיכרון קבוע
mkdir %USERPROFILE%\.claude\projects 2>nul
copy memory\MEMORY.md %USERPROFILE%\.claude\projects\memory\MEMORY.md
```

### Linux

```bash
# 1. התקנת דרישות מוקדמות
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs git
npm install -g @anthropic-ai/claude-code

# 2. שכפול
git clone https://github.com/Tokenized2027/Claude-Initilization-V7.git ~/Claude
cd ~/Claude

# 3. אותו דבר כמו שלבים 3-5 ב-Mac
```

### הפרויקט הראשון שלכם

```bash
mkdir -p ~/projects/my-app && cd ~/projects/my-app && git init
cp $CLAUDE_HOME/examples/CLAUDE.md ./CLAUDE.md    # מעתיקים את התבנית
# עורכים את CLAUDE.md עם הפרטים של הפרויקט, ואז:
claude
```

זהו. אתם בפנים.

## מה מקבלים

### הבסיס (משתמשים מהיום הראשון)

| רכיב | מה הוא עושה |
|------|-------------|
| **Session Recall Hook** | Claude זוכר אוטומטית את 48 השעות האחרונות של העבודה שלכם כשמתחילים שיחה חדשה. בלי להסביר מחדש. |
| **תבניות CLAUDE.md** | שמים קובץ CLAUDE.md בכל פרויקט כדי לספר ל-Claude את הכללים, הסטאק, והמוסכמות שלכם. הוא קורא את זה אוטומטית. |
| **זיכרון תלת שכבתי** | חם (נטען תמיד), פושר (לפי דרישה), קר (היסטוריית git). שומר על ההקשר של Claude מאורגן בלי לפרוץ מגבלות. |
| **YOUR_WORKING_PROFILE.md** | תבנית שמגדירה איך Claude מתקשר איתכם, מוסר קוד, ומטפל בשגיאות. ממלאים פעם אחת, משתמשים בכל מקום. |

### הפריימוורק (כשכבר בנוח)

| רכיב | מה הוא עושה |
|------|-------------|
| **13 תבניות סוכנים** | תפקידים מתמחים: Frontend Dev, Backend Dev, Security Auditor, Product Manager ועוד. נותנים ל-Claude התנהגות מומחית למשימות ספציפיות. |
| **28 כלי אוטומציה** | משימות חוזרות: שחזור git, דיבאג Docker, תיקון שגיאות בילד, יצירת API, סריקת אבטחה, ביקורת SEO. |
| **Hooks בטיחות** | הגנה על branches, חסימת פקודות מסוכנות, זיהוי סודות, פרמוט אוטומטי. מונעים טעויות יקרות. |
| **תבניות פרויקט** | CLAUDE.md, PRD, Sprint, Status, Tech Spec. מתחילים כל פרויקט עם מבנה. |

### המערכת האוטונומית (מתקדם, אופציונלי)

| רכיב | מה הוא עושה |
|------|-------------|
| **מתזמר רב סוכנים** | שרת FastAPI שמנתב משימות לסוכנים מתמחים. שולחים משימה, הסוכנים מתאמים, מקבלים תוצאות. |
| **בוט Telegram** | שולטים בהכל מהטלפון. פקודות קוליות, התראות push, פקודות slash. |
| **שירות Whisper** | המרת דיבור לטקסט בקונטיינר Docker. שולחים הודעה קולית, מקבלים טקסט. |
| **תשתית שרת** | מדריך מלא להקמת שרת ייעודי שרץ 24/7 עם מערכת הסוכנים. |

## איך הכל מתחבר

```
אתם (מחשב נייד / טלפון)
    |
    +-- claude (CLI)              -> קידוד ישיר עם Claude Code + זיכרון + hooks
    |
    +-- בוט Telegram (טלפון)      -> פקודות קול/טקסט -> מתזמר -> סוכנים
    |
    +-- Cursor IDE (מחשב)         -> עריכה ויזואלית, מחובר לשרת דרך SSH
            |
            +-- שרת (פועל תמיד)
                    +-- מתזמר (מנתב משימות)
                    +-- 14 תבניות סוכנים (עושים את העבודה)
                    +-- שרתי MCP (זיכרון + הקשר)
                    +-- Whisper (קול לטקסט)
```

## מדריכים

| אני רוצה... | לקרוא את זה |
|---|---|
| **ללמוד בסיסי טרמינל** | `claude-code-framework/essential/guides/DAY_ZERO.md` |
| **לבנות את הפרויקט הראשון** | `claude-code-framework/essential/guides/FIRST_PROJECT.md` |
| **להבין את העבודה היומיומית** | `claude-code-framework/essential/guides/DAILY_WORKFLOW.md` |
| **להגדיר hooks (זיכרון בין שיחות)** | `hooks/README.md` |
| **להבין את מערכת הזיכרון** | `memory/guidelines.md` |
| **ללמוד Git בלי לדעת לתכנת** | `claude-code-framework/essential/guides/GIT_FOR_VIBE_CODERS.md` |
| **להימנע מטעויות נפוצות** | `claude-code-framework/essential/guides/PITFALLS.md` |
| **לתקן משהו שנשבר** | `claude-code-framework/essential/guides/TROUBLESHOOTING.md` |
| **לחסוך בעלויות API** | `claude-code-framework/advanced/guides/PROMPT_CACHING.md` |
| **להקים שרת 24/7** | `claude-code-framework/advanced/infrastructure/README.md` |
| **להפעיל את מערכת הסוכנים** | `multi-agent-system/docs/DEPLOYMENT_GUIDE.md` |

## מבנה תיקיות

```
+-- setup-mac.sh                    <- התקנה אוטומטית ל-Mac
+-- YOUR_WORKING_PROFILE.md         <- תבנית: איך Claude עובד איתכם
+-- hooks/                          <- זיכרון בין שיחות + hooks בטיחות
+-- memory/                         <- מערכת זיכרון תלת שכבתית + תבניות
+-- examples/                       <- תבניות CLAUDE.md (ריקה + מלאה)
+-- dot-claude/                     <- הגדרות Claude Code
+-- claude-code-framework/
|   +-- essential/
|   |   +-- agents/                 <- 13 תבניות סוכנים
|   |   +-- guides/                 <- 10 מדריכים
|   |   +-- skills/                 <- 28 כלי אוטומציה
|   |   +-- toolkit/                <- סקריפטים + תבניות פרויקט
|   +-- advanced/
|       +-- guides/                 <- Caching, MCP, Team Mode, ארכיטקטורה
|       +-- infrastructure/         <- הקמת שרת (6 שלבים)
+-- multi-agent-system/             <- מתזמר אוטונומי + 14 סוכנים + שרתי MCP
+-- telegram-bot/                   <- שליטה מרחוק מהטלפון
+-- whisper-service/                <- המרת דיבור לטקסט (Docker)
+-- project-contexts/               <- תיעוד לפי פרויקט
+-- templates/                      <- Docker + תבניות בסיס
```

## שאלות נפוצות

**צריך לדעת לתכנת?**
לא. נוחות בסיסית עם טרמינל עוזרת (cd, ls, העתקה והדבקה של פקודות), אבל זה הכל. המדריך `DAY_ZERO.md` מכסה את כל מה שצריך.

**מה זה קובץ CLAUDE.md?**
קובץ ששמים בתיקייה הראשית של הפרויקט ו-Claude קורא אותו אוטומטית בתחילת כל שיחה. הוא אומר ל-Claude מה הכללים, מה הסטאק, ומה המוסכמות של הפרויקט. זה הקובץ הכי חשוב ב-Claude Code.

**מה זה Hooks?**
סקריפטים שרצים אוטומטית ברגעים ספציפיים (תחילת שיחה, לפני/אחרי פעולה, סוף שיחה). ה-hook הכי משמעותי הוא Session Recall: הוא מזריק סיכומים של 48 השעות האחרונות כדי ש-Claude יידע מה עשיתם בלי שתצטרכו להסביר מחדש.

**רק ל-Mac?**
סקריפט ההתקנה הוא ל-Mac בלבד, אבל כל קבצי הפריימוורק (תבניות CLAUDE.md, סוכנים, כלי אוטומציה, מערכת זיכרון, hooks) עובדים על כל מערכת הפעלה. משתמשי Windows ו-Linux פשוט מתקינים את הדרישות המוקדמות ידנית.

**כמה זה עולה בחודש?**
Claude Pro ב-$20 זה המינימום. Claude Max ($100) + OpenAI API (~$10) + שרת (~$15) למערכת האוטונומית המלאה יוצא בערך $120/חודש.

**מה ההבדל בין סוכנים לכלי אוטומציה?**
סוכנים (Agents) הם הנחיות תפקיד שמשנות את הדרך שבה Claude מתנהג (תחשבו: "אתה מבקר אבטחה"). כלי אוטומציה (Skills) הם תהליכים צעד אחר צעד למשימות ספציפיות (תחשבו: "שחזר לי את הריפו של git"). סוכנים מעצבים חשיבה, כלים מעצבים פעולה.

## צ׳קליסט

- [ ] מחשב עם 16GB+ RAM
- [ ] מנוי Claude Pro או Max (פעיל)
- [ ] Node.js v20+ מותקן
- [ ] Git מותקן
- [ ] חשבון GitHub
- [ ] Claude Code CLI מותקן (`npm install -g @anthropic-ai/claude-code`)
- [ ] ריפו זה משוכפל
- [ ] הגדרות הועתקו ל-`~/.claude/`
- [ ] Hooks מותקנים
- [ ] MEMORY.md מוגדר עם המידע שלכם
- [ ] CLAUDE.md נוסף לפרויקט הראשון
- [ ] OpenAI API Key (אופציונלי, לקול)
- [ ] פרויקט Google Cloud (אופציונלי, ליומן/מייל)
- [ ] בוט Telegram נוצר (אופציונלי, לשליטה מהטלפון)

## רישיון

MIT

</div>
