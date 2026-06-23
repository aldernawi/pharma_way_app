# 🎨 دليل تغيير أيقونة التطبيق (App Icon)

## ✅ تم تغيير اسم التطبيق

تم تغيير اسم التطبيق من `pharma_way` إلى **PHARMA WAY** ✅

---

## 📱 خطوات تغيير أيقونة التطبيق

### الطريقة 1: استخدام flutter_launcher_icons (الأسهل والأفضل) ⭐

#### الخطوة 1: إضافة الحزمة

أضف في `pubspec.yaml` تحت `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

#### الخطوة 2: إعداد الأيقونة

1. **احصل على لوقو المشروع** بصيغة PNG
2. ضعه في مجلد `assets/images/` باسم `app_icon.png`
3. **الحجم المثالي**: 1024x1024 بكسل

#### الخطوة 3: إضافة الإعدادات

أضف في نهاية `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false  # غيرها لـ true إذا كنت تستخدم iOS
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#1F66A6"  # اللون الأساسي للمشروع
  adaptive_icon_foreground: "assets/images/app_icon.png"
```

#### الخطوة 4: تشغيل الأمر

```bash
# ثبت الحزمة
flutter pub get

# أنشئ الأيقونات
flutter pub run flutter_launcher_icons
```

#### الخطوة 5: إعادة البناء

```bash
flutter clean
flutter pub get
flutter run
```

---

### الطريقة 2: يدوياً (للتحكم الكامل)

#### للأندرويد:

تحتاج إنشاء أحجام مختلفة من اللوقو:

| المجلد | الحجم |
|--------|-------|
| `mipmap-mdpi` | 48x48 |
| `mipmap-hdpi` | 72x72 |
| `mipmap-xhdpi` | 96x96 |
| `mipmap-xxhdpi` | 144x144 |
| `mipmap-xxxhdpi` | 192x192 |

**المسار**: `android/app/src/main/res/`

**الخطوات**:
1. أنشئ الأحجام المختلفة من اللوقو
2. ضعها في المجلدات المناسبة
3. سمّها `ic_launcher.png`

---

## 🎨 مواصفات اللوقو المثالية

### التصميم:
- ✅ **الحجم الأساسي**: 1024x1024 بكسل
- ✅ **الشكل**: مربع (سيتم قصه تلقائياً لدائرة في بعض الأجهزة)
- ✅ **الخلفية**: شفافة أو بلون `#1F66A6` (اللون الأساسي)
- ✅ **الألوان**: استخدم ألوان المشروع (#1F66A6, #F06A1A)

### التنسيق:
- ✅ **الصيغة**: PNG
- ✅ **الجودة**: عالية (لا تستخدم صور منخفضة الجودة)
- ✅ **البساطة**: تصميم بسيط وواضح يظهر جيداً بأحجام صغيرة

---

## 🔧 أدوات مساعدة

### 1. App Icon Generator Online:
- https://appicon.co/
- https://icon.kitchen/
- https://easyappicon.com/

### 2. تصميم اللوقو:
- Canva: https://www.canva.com/
- Figma: https://www.figma.com/
- Adobe Illustrator

---

## 📋 Checklist

- [ ] حصلت على لوقو المشروع بحجم 1024x1024
- [ ] أضفت حزمة `flutter_launcher_icons` في `pubspec.yaml`
- [ ] وضعت اللوقو في `assets/images/app_icon.png`
- [ ] أضفت إعدادات `flutter_launcher_icons` في `pubspec.yaml`
- [ ] شغّلت `flutter pub get`
- [ ] شغّلت `flutter pub run flutter_launcher_icons`
- [ ] شغّلت `flutter clean && flutter run`
- [ ] تحققت من ظهور اللوقو الجديد على الهاتف

---

## 🎯 مثال على اللوقو المناسب

```
┌─────────────────────┐
│                     │
│    🏥 PHARMA WAY   │
│                     │
│   [أيقونة صيدلية]  │
│                     │
│   #1F66A6 خلفية    │
│                     │
└─────────────────────┘
```

---

## ⚠️ ملاحظات مهمة

1. **بعد تغيير اللوقو**:
   - احذف التطبيق من الهاتف
   - أعد تثبيته من جديد
   - أو شغّل `flutter clean` قبل `flutter run`

2. **Adaptive Icons** (أندرويد 8+):
   - استخدم `adaptive_icon_background` و `adaptive_icon_foreground`
   - الخلفية: لون ثابت (#1F66A6)
   - المقدمة: اللوقو نفسه

3. **iOS** (إذا كنت تستخدمه):
   - غير `ios: true` في الإعدادات
   - قد تحتاج Xcode لبعض التعديلات

---

## 🚀 الأمر السريع (بعد إعداد كل شي)

```bash
flutter pub get && flutter pub run flutter_launcher_icons && flutter clean && flutter run
```

---

## 📞 للمساعدة

إذا واجهت مشكلة:
1. تأكد من مسار اللوقو صحيح
2. تأكد من حجم اللوقو 1024x1024
3. شغّل `flutter clean` قبل `flutter run`
4. احذف التطبيق وأعد تثبيته

---

**ملاحظة**: اسم التطبيق تم تغييره بالفعل إلى **PHARMA WAY** ✅
