/**
 * ReadExcelFormatClipboard
 *
 * @date 17/10/2024
 * @createdBy wrnunzio
 * @modifiedBy
 * @history
 */
public virtual without sharing class ReadExcelFormatClipboard {
    
    
    //as this is an apex class it can only handle 6MB of heap size
    // so a cautious limit must be put in place
    private static final Integer MAX_NUMBER_OF_CHARACHTERS = 4 * 1000000; //roughly 4 mb
    
    private String excelTableString = '';
    private Boolean isFromAura = false;
    private Boolean manageErrors = false;
    private Integer numeberOfErrorsAfterValidation = 0;
    
    private List<String> possibleColumnsHeaders = new List<String>{
            'Proprietario', 'Stato', 'Fase', 'Note'
    };
    private List<String> requiredColumnsHeaders = new List<String>{
            'Proprietario', 'Stato', 'Note'
    };
    
    public class ReadExcelFormatClipboardException extends Exception {
    
    }
    
    /**
     * @param excelTableString exel table from clipboard it should include columns header
     */
    public ReadExcelFormatClipboard(String excelTableString) {
        this.excelTableString = excelTableString;
    }
    
    //names only list
    public ReadExcelFormatClipboard setPossibleColumnsHeaders(List<String> names) {
        this.possibleColumnsHeaders = names;
        return this;
    }
    //names only list
    public ReadExcelFormatClipboard setRequiredColumnsHeaders(List<String> names) {
        this.requiredColumnsHeaders = names;
        return this;
    }
    public ReadExcelFormatClipboard fromAura(Boolean isFromAura) {
        this.isFromAura = isFromAura;
        return this;
    }
    
    public ReadExcelFormatClipboard manageErrors(Boolean manage) {
        this.manageErrors = manage;
        return this;
    }
    
    
    public class Validation {
        @AuraEnabled
        public String typex;
        @AuraEnabled
        public List<ValidationRow>validationRows; //header name, error/warning description
        public Validation(ValidationEnum typex, List<ValidationRow>validationRows) {
            this.typex = typex.name();
            this.validationRows = validationRows;
        }
    }
    
    public class ValidationRow {
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String description;
        public ValidationRow(String fieldName, String description) {
            this.description = description;
            this.fieldName = fieldName;
        }
    }
    
    public enum ValidationEnum {
        ERROR, WARNING, VALIDATION_ERROR, VALIDATION_WARNING
    }
    
    public static final String REQUIRED_FIELD_ERROR = 'Missing required header';
    public static final String FIELD_NOT_RECOGNIZED = 'Unexpected header';
    public static final String VALIDATED = null;
    
    public virtual ConvertResult customValidations(ConvertResult result) {
        return result;
    }
    
    private List<Validation> validateHeaders(List<String> headers) {
        Map<String, ValidationRow>validationRowsErrors = new Map<String, ValidationRow>();
        Map<String, ValidationRow>validationRowsWarnings = new Map<String, ValidationRow>();
        List<Validation> validations = new List<Validation>();
        //prepopulate map with required fields
        for (Integer x = 0; x < requiredColumnsHeaders.size(); x++) {
            validationRowsErrors.put(requiredColumnsHeaders[x], new ValidationRow(requiredColumnsHeaders[x], REQUIRED_FIELD_ERROR));
        }
        
        for (Integer x = 0; x < requiredColumnsHeaders.size(); x++) {
            for (Integer i = 0; i < headers.size(); i++) {
                String currentHeader = headers[i];
                if (requiredColumnsHeaders[x] == currentHeader) {
                    validationRowsErrors.put(requiredColumnsHeaders[x], new ValidationRow(requiredColumnsHeaders[x], VALIDATED));
                }
            }
        }
        
        
        for (Integer x = 0; x < headers.size(); x++) {
            if (!possibleColumnsHeaders.contains(headers[x])) {
                validationRowsWarnings.put(headers[x], new ValidationRow(headers[x], FIELD_NOT_RECOGNIZED));
                System.debug('Warning: Unexpected header' + headers[x]);
            }
        }
        validations.add(new Validation(ValidationEnum.VALIDATION_WARNING, validationRowsWarnings.values()));
        
        validationRowsErrors = reduce(validationRowsErrors.values());
        validations.add(new Validation(ValidationEnum.VALIDATION_ERROR, validationRowsErrors.values()));
        
        numeberOfErrorsAfterValidation = validationRowsErrors.values().size();
        
        if (!validationRowsErrors.isEmpty() && !manageErrors) {
            if (isFromAura) {
                throw new AuraHandledException('Missing required header: ' + validationRowsErrors);
            }
            throw new ReadExcelFormatClipboardException('Missing required header: ' + validationRowsErrors);
        }
        
        return validations;
    }
    
    private Map<String, ValidationRow> reduce(List<ValidationRow>r) {
        Map<String, ValidationRow>res = new Map<String, ValidationRow>();
        for (ValidationRow row : r) {
            if (!String.isBlank(row.description)) {
                res.put(row.fieldName, row);
            }
        }
        return res;
    }
    
    private List<String>normalizeHeaders(List<String> headers) {
        List<String> normalizedHeaders = new List<String>();
        for (String header : headers) {
            normalizedHeaders.add(header.trim());
        }
        return normalizedHeaders;
    }
    
    public class ConvertResult {
        @AuraEnabled
        public List<Validation>validations;
        @AuraEnabled
        public Map<Integer, Map<String, String>>mappedExcelTable;
        public ConvertResult(List<Validation>validations, Map<Integer, Map<String, String>>mappedExcelTable) {
            this.validations = validations;
            this.mappedExcelTable = mappedExcelTable;
        }
    }
    
    
    public ConvertResult convert() {
        
        if (excelTableString.length() > MAX_NUMBER_OF_CHARACHTERS) {
            if (isFromAura) {
                throw new AuraHandledException('The provided table is too large. Please limit it to' + MAX_NUMBER_OF_CHARACHTERS / 1000000 + 'MB.');
            }
            throw new ReadExcelFormatClipboardException('The provided table is too large. Please limit it to' + MAX_NUMBER_OF_CHARACHTERS / 1000000 + 'MB.');
        }
        
        //map containing the row number as key and e  row values map as value
        Map<Integer, Map<String, String>> mappedExcelTable = new Map<Integer, Map<String, String>>();
        List<String> rows = excelTableString.split('\n');
        List<String> headers = rows[0].split('\t');
        
        System.debug('##rows## ' + rows.size());
        System.debug('##headers## ' + headers.size());
        
        headers = normalizeHeaders(headers);
        List<Validation> validations = validateHeaders(headers);
        
        //cycling rows, starting from index 1 to exclude columns
        for (Integer x = 1; x < rows.size(); x++) {
            List<String>currentRowValues = new List<String>(rows.get(x).split('\\t'));
            
            //matching list size with empty values
            while (currentRowValues != null && currentRowValues.size() < headers.size()) {
                currentRowValues.add('');
            }
            System.debug('##currentRowValues## ' + currentRowValues.size());
            
            for (Integer i = 0; i < headers.size(); i++) {
                String currentHeader = headers[i];
                
                String currentRowValue = currentRowValues.get(i);
                if (mappedExcelTable.get(x) == null) {
                    mappedExcelTable.put(x, new Map<String, String>{
                            currentHeader => currentRowValue
                    });
                } else {
                    mappedExcelTable.get(x).put(currentHeader, currentRowValue);
                }
            }
        
        }
        
        ConvertResult result = new ConvertResult(validations, mappedExcelTable);
        
        //custom validation are applying only if no formal validation error are present
        if (numeberOfErrorsAfterValidation == 0) {
            result = customValidations(result);
        }
        
        return result;
    }

}