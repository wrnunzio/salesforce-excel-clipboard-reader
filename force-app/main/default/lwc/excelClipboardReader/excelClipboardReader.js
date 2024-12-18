/**
 * excelClipboardRerader
 * @date 21/10/2024
 * @createdBy wrnunzio
 * @modifiedBy
 * @history
 */
import {LightningElement, track} from 'lwc';
import convert from '@salesforce/apex/ReadExcelFormatClipboardAuraCtrl.convertfa';

export default class ExcelClipboardReader extends LightningElement {

    @track currentPastedTable = '';
    disabledTextArea = false;
    pasted = false;
    showSpinner = false;
    @track errors = []
    @track warnings = []

    async saveClip(event) {
        console.log('##eventkeycode##', event.keyCode);
        //wait for the text to be fully loaded before processing it.
        await new Promise((resolve) => setTimeout(() => resolve(), 5));

        //waiting for CRTL+V
        if (event.ctrlKey && event.keyCode === 86) {
            this.currentPastedTable = Object.assign({}, {text: this.refs.excelClip.value});
            this.disabledTextArea = true;
            this.pasted = true;
            this.refs.excelClip.scrollTop = 0;
        } else {
            this.cancel(null, this.pasted);
        }
    }

    cancel(event, keepValue) {
        if (!keepValue) {
            if(this.refs.excelClip){
                this.refs.excelClip.value = '';
            }
            this.currentPastedTable = '';
            this.pasted = false;
            this.errors=[];
            this.warnings=[];
        }
        this.disabledTextArea = false;
    }

    convert(event) {
        console.log('##e##', this.currentPastedTable.text);

        this.showSpinner=true;
        convert({tableAsString: this.currentPastedTable.text}).then(res => {
            console.log('##res##', res);
            for (let validation of res.validations) {

       /*         for (const [key, value] of Object.entries(r.validationMap)) {
                    console.log(`${key}: ${value}`);
                    if (r.typex.includes('WARNING')) {
                        this.warnings = [...this.warnings, {name:key,value:value,typex:r.typex.replaceAll('_',' ')}];
                    } else if (r.typex.includes('ERROR')) {
                        this.errors = [...this.errors, {name:key,value:value,typex:r.typex.replaceAll('_',' ')}];
                    }
                }*/

                for (let validationRow of validation.validationRows) {
                    if (validation.typex.includes('WARNING')) {
                        this.warnings = [...this.warnings, validationRow];
                    } else if (validation.typex.includes('ERROR')) {
                        this.errors = [...this.errors, validationRow];
                    }
                }

            }
            console.table(res.mappedExcelTable);
            this.showSpinner=false;
        }).catch(err => {
            console.log('####', err);
            this.showSpinner=false;
        })
    }

    get disableImpBtn() {
        return !this.pasted;
    }

    get showWarnings() {
        return this.warnings.length > 0;
    }

    get showErrors() {
        return this.errors.length > 0;
    }
    get showErrorsOrWarnings(){
        return this.showErrors || this.showWarnings;
    }
}