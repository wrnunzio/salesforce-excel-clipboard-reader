# 📝 Excel/GoogleSheet Table reader/converter (salesforce-excel-clipboard-reader)

This project provides a Salesforce-based application built with Apex and Lightning Web Components (LWC) that converts an Excel or Google Sheets table copied from the clipboard into a structured Salesforce-compatible format. The application includes validations for headers, warnings for unrecognized fields, and error handling for missing required columns.

---

## 🌟 Features

- 📋 **Paste from Clipboard:** Accepts Excel or Google Sheets tables copied to the clipboard.
- ✅ **Header Validation:** Ensures required headers are present and flags unexpected headers as warnings.
- ⚠️ **Error Handling:** Displays errors for missing required fields and prevents data import if errors are found.
- 🔔 **Warnings:** Provides warnings for unexpected fields while still allowing data import.
- 👀 **Data Preview:** Displays errors and warnings in a formatted table for review before committing changes.
- 📈 **Scalability:** Supports up to 4 MB of data to prevent heap size limitations in Salesforce.

---

## 🏗️ Architecture

The solution includes the following components:

- ⚡ **Lightning Web Component (LWC):**
    - **HTML:** Handles the user interface for pasting data and displaying errors/warnings.
    - **JavaScript:** Implements logic for processing the pasted data, interacting with Apex, and rendering results.

- 🛠️ **Apex Controller:**
    - `ReadExcelFormatClipboardAuraCtrl`: Acts as the bridge between the LWC and the main Apex logic.

- 📚 **Apex Logic Class:**
    - `ReadExcelFormatClipboard`: Contains the core logic for parsing and validating the Excel data, as well as mapping rows to Salesforce-compatible format (a Map).

---

## ⚙️ How It Works

1. 👩‍💻 The user pastes an Excel or Google Sheets table into the provided text area in the LWC.
2. 🔄 The `saveClip` function in JavaScript processes the clipboard data and disables the textarea.
3. 📤 The `convert` method sends the data to the Apex controller (`ReadExcelFormatClipboardAuraCtrl`), which processes the data using `ReadExcelFormatClipboard`.
4. 🛡️ Header validations and custom rules are applied.
5. 📋 Errors and warnings are returned to the LWC for display.
6. ✔️ If no errors are present, the user can proceed with importing the data.

---

## 🧪 Validations

- 🟩 **Required Headers:** Ensures fields like `Proprietario`, `Stato`, and `Note` are present, those can be customized to your liking using `setRequiredColumnsHeaders` method.
- 🟨 **Unexpected Headers:** Warns for fields not in the predefined list of possible headers  those can be customized to your liking using `setPossibleColumnsHeaders` method.

---

## 🛠️ Usage Instructions

1. 📋 Copy a table from Excel or Google Sheets.
2. 🖋️ Paste the table into the text area of the Lightning Web Component.
3. ✅ Click the **Validate Inputs** button.
4. 👀 Review errors or warnings in the displayed table.
5. 🚀 If no errors are present, click **Import** to proceed.
6. 🔄 Use **Cancel** to clear the input and reset the component.

---

## 📊 Technical Details

- **LWC Components:**
    - 🖼️ **HTML:** Handles the text area for pasting data, displays errors and warnings in tables, and includes action buttons for validation and import.
    - 🧩 **JavaScript:** Implements the logic for handling user interactions, sending data to Apex, and managing the state of the component.

- **Apex Components:**
    - ⚙️ **Controller:** `ReadExcelFormatClipboardAuraCtrl`
        - Provides the `convertfa` method for converting the pasted table.
    - 📖 **Logic Class:** `ReadExcelFormatClipboard`
        - Validates headers, maps rows to a structured format, and handles custom validation logic.

---

## 🛠️ Future Improvements

- 📝 Improve error descriptions for better clarity.
- 🚀 Optimize performance for larger datasets.

---

## 📸 Screenshots

*(Add screenshots here showing the application in action.)*



---  

Let me know if you'd like me to tweak or add anything else! 😊