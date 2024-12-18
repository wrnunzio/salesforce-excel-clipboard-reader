/**
 * ReadExcelFormatClipboardAuraCtrl
 *
 * @date 22/10/2024
 * @createdBy wrnunzio
 * @modifiedBy
 * @history
 */
public without sharing class ReadExcelFormatClipboardAuraCtrl {
    
    public class ReadExcelFormatClipboardOverride extends ReadExcelFormatClipboard {
        public ReadExcelFormatClipboardOverride(String excelTableString) {
            super(excelTableString);
        }
        
        public override ReadExcelFormatClipboard.ConvertResult customValidations(ReadExcelFormatClipboard.ConvertResult result) {
            return super.customValidations(result);
        }
    }
    
    @AuraEnabled
    public static Object convertfa(String tableAsString) {
        return new ReadExcelFormatClipboardOverride(tableAsString)
                .fromAura(true)
                .manageErrors(true)
                .convert();
    }
}