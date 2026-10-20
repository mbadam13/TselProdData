import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import IMG_TICK from '@salesforce/resourceUrl/icon_tick';
import IMG_EMAIL from '@salesforce/resourceUrl/email_icon';
import TADEX_LOGO from '@salesforce/resourceUrl/tadex_logo';

export default class HeaderTadex extends NavigationMixin(LightningElement){
    svgTick = `${IMG_TICK}#Tick`
    imgEmail = `${IMG_EMAIL}#email`
    tadexLogo = `${TADEX_LOGO}#logo`
    @track showModal = false;
    @track banner = true;
    @track info = false;
    @track successPage = false;

    handleShowModal(){
        this.showModal = true;
    }

    handleShowInformation(){
        this.info = true;
        this.banner = false;
    }

    handleBackInformation(){
        this.banner = true;
        this.info = false;
    }

    handleHideModal(){
        this.showModal = false;
    }

    backHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

    informationPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'information'
            },
        });
    }

    handleStatusChange(event) {
       
        console.log('event==> '+  JSON.stringify(event.detail));
        if (event.detail.locationName === 'OkScreen') {
            this.successPage = true;
            this.banner = false;
        }
    }
}