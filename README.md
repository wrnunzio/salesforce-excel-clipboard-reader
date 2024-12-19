# 📋 Excel Clipboard Reader

### 📝 Overview

The **Excel Clipboard Reader** is a Salesforce Lightning Web Component (LWC) that enables users to paste data from Excel or Google Sheets into a text area. The component processes the pasted data, performs validations, and displays errors ⚠️ or warnings ℹ️ if any issues are found. The backend logic in Apex processes the data and returns a mapped table for further use.

---  

## ✨ Features

1. **User Interface (LWC):**
    - 🖊️ Provides a text area for pasting Excel/Google Sheets data.
    - ⚠️ Displays errors and ℹ️ warnings in a structured table format if the input validation fails.
    - ✅ Allows users to import validated data for further processing.

2. **Backend (Apex):**
    - 🛠️ Parses the pasted Excel/Google Sheets content and converts it into a structured map.
    - 🔍 Validates the input for missing or unrecognized columns.
    - 🧩 Supports custom validation rules.

---  

## 🔧 Implementation Details

### 📘 Apex Logic

#### **Class: `ReadExcelFormatClipboard`**

- **📌 Purpose:**  
  This class performs the core logic of processing the pasted Excel data string. It splits the input into rows and columns, validates the headers, and maps the data to a structured format.

- **Key Features:**
    - ✅ Validates headers to ensure required fields are present and no unexpected fields exist.
    - 🔄 Supports custom validation logic using the `customValidations` method.
    - ⚡ Throws exceptions if the data is too large or validation errors are found (configurable for Aura or non-Aura contexts).
    - 📋 Outputs the data as a `ConvertResult` containing validations and the mapped table.
    - 🟩 Supports configurable column headers:
        - Set **possible headers** using `setPossibleColumnsHeaders`.
        - Set **required headers** using `setRequiredColumnsHeaders`.

---

#### **Class: `ReadExcelFormatClipboardAuraCtrl`**

- **📌 Purpose:**  
  Extends `ReadExcelFormatClipboard` and exposes its functionality for Aura and Lightning contexts.

- **Key Features:**
    - 🖱️ Provides a static `convertfa` method to be called from LWC or Aura.
    - 📤 Wraps exceptions in Aura-handled exceptions for user-friendly error messages.

---  

### ⚡ Lightning Web Component (LWC)

#### 🖼️ **HTML File:**
Provides the structure of the component:
- 🖋️ **Text Area:** For users to paste Excel/Google Sheets data.
- ⚠️ **Validation Tables:** Displays errors and warnings when the input is processed.
- 🖱️ **Buttons:** For validating and importing data.

#### 💻 **JavaScript File:**
Handles the logic for processing user input and interacting with the backend.
- **Methods:**
    - 🗂️ `saveClip(event)`: Captures the pasted Excel data and prepares it for processing.
    - 🔄 `convert(event)`: Sends the pasted data to the backend for processing and handles the response.
    - ❌ `cancel(event, keepValue)`: Clears the pasted data and resets the UI.
    - 🚀 `handleImport()`: Placeholder for handling the imported, validated data.
- **Getters:**
    - 🎛️ Dynamically control the visibility of errors, warnings, and button states.

---  

## 🚀 How to Use

### 1️⃣ Usage
- 📋 Copy a table from Excel or Google Sheets.
- 📋 Paste it into the text area of the component.
- 🖱️ Click "Validate Inputs" to process the data and view any ⚠️ errors or ℹ️ warnings.
- ✅ If no errors exist, click "Import" to handle the validated data.

---  

## 🛠️ Customization

### 🟩 Setting Possible and Required Columns

The `ReadExcelFormatClipboard` class provides two methods to configure column headers:
- **`setPossibleColumnsHeaders`:** 🟩 Define all columns that are allowed in the pasted data.
- **`setRequiredColumnsHeaders`:** 🟥 Specify the columns that must exist in the pasted data.

**Example Usage:**
```apex  
ReadExcelFormatClipboard clipboardProcessor = new ReadExcelFormatClipboard(pastedExcelData);  
clipboardProcessor.setPossibleColumnsHeaders(new Set<String>{'Proprietario', 'Stato', 'Fase', 'Note'});  
clipboardProcessor.setRequiredColumnsHeaders(new Set<String>{'Proprietario', 'Stato'});  
```  

### 🧩 Validations
To customize validation rules:  
1️⃣ Extend the `ReadExcelFormatClipboard` class and override the `customValidations` method.  
2️⃣ Add your custom logic and apply it to the `ConvertResult`.

### ⚡ Error Handling
Errors ⚠️ and warnings ℹ️ can be displayed or managed by modifying the LWC's JavaScript logic or Apex methods.

---  

## 📊 Example Output

### 📋 **Input (Pasted Table):**
| Proprietario | Stato    | Fase  | Note  |  
|--------------|----------|-------|-------|  
| John Doe     | Active   | Start | Note1 |  
| Jane Smith   | Inactive | End   | Note2 |  

### 📤 **Output (Mapped Table):**
```json  
{  
  "1": {  
    "Proprietario": "John Doe",  
    "Stato": "Active",  
    "Fase": "Start",  
    "Note": "Note1"  
  },  
  "2": {  
    "Proprietario": "Jane Smith",  
    "Stato": "Inactive",  
    "Fase": "End",  
    "Note": "Note2"  
  }  
}  
```  
