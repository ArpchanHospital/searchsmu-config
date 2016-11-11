Bahmni.ConceptSet.FormConditions.rules = {
    'DM Follow, Medicine dispensed to' : function (formName, formFieldValues) {
        var result = formFieldValues['DM Follow, Medicine dispensed to'];
        if (result == "Other") {
            return {
                enable: ["DM Follow, Medicine dispense other"]
            }
        } else {
            return {
                disable: ["DM Follow, Medicine dispense other"]
            }
        }
    },
    'HTN Follow, Medicine dispensed to' : function (formName, formFieldValues) {
        var result = formFieldValues['HTN Follow, Medicine dispensed to'];
        if (result == "Other") {
            return {
                enable: ["HTN Follow, Medicine dispense other"]
            }
        } else {
            return {
                disable: ["HTN Follow, Medicine dispense other"]
            }
        }
    },
    'Stroke Follow, Medicine dispensed to' : function (formName, formFieldValues) {
        var result = formFieldValues['Stroke Follow, Medicine dispensed to'];
        if (result == "Other") {
            return {
                enable: ["Stroke Follow, Medicine dispense other"]
            }
        } else {
            return {
                disable: ["Stroke Follow, Medicine dispense other"]
            }
        }
    },
    'DM Follow, ADRs' : function (formName, formFieldValues) {
        var result = formFieldValues['DM Follow, ADRs'];
        if (result == "SAE") {
            return {
                enable: ["DM Follow, SAE description"]
            }
        } 
        else if (result == "Other") {
            return {
                enable: ["DM Follow, Other description"]
            }
        } else {
            return {
                disable: ["DM Follow, Other description", "DM Follow, SAE description"]
            }
        }
    },
    'HTN Follow, ADRs' : function (formName, formFieldValues) {
        var result = formFieldValues['HTN Follow, ADRs'];
        if (result == "SAE") {
            return {
                enable: ["HTN Follow, SAE description"]
            }
        } 
        else if (result == "Other") {
            return {
                enable: ["HTN Follow, Other description"]
            }
        } else {
            return {
                disable: ["HTN Follow, Other description", "HTN Follow, SAE description"]
            }
        }
    },
    'Stroke Follow, ADRs' : function (formName, formFieldValues) {
        var result = formFieldValues['Stroke Follow, ADRs'];
        if (result == "SAE") {
            return {
                enable: ["Stroke Follow, SAE description"]
            }
        } 
        else if (result == "Other") {
            return {
                enable: ["Stroke Follow, Other description"]
            }
        } else {
            return {
                disable: ["Stroke Follow, Other description", "Stroke Follow, SAE description"]
            }
        }
    },
    'DM Follow, Is the patient present?' : function (formName, formFieldValues) {
        var result = formFieldValues['DM Follow, Is the patient present?'];
        if (result=="Yes") {
            return {
                enable: ["DM Follow, Height",
                "DM Follow, Weight",
                "DM Follow, BMI","Random Blood Sugar Data",
                "Blood Pressure",
                "DM Follow, Prescribed medications",
                "DM Follow, Has the patient taken todays medicines as instructed",
                "DM Follow, Number of times food is taken in a day",
                "DM Follow, Patient is taking",
                "DM Follow, How many days patient is out of medicines?",
                "DM Follow, Have the patient stopped the medicines?",
                "DM Follow, ADRs",
                "DM Follow, Days",
                "DM Follow, Any cardiac chest pain since the last clinic visit?",
                "DM Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "DM Follow, since last visit, did the patient have weakness on one side of his body?",
                "DM Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "DM Follow, Rx, Metformin, Morning",
                "DM Follow, Rx, Metformin, Afternoon",
                "DM Follow, Rx, Metformin, Night",
                "DM Follow, Rx, Glipizide, Morning",
                "DM Follow, Rx, Glipizide, Afternoon",
                "DM Follow, Rx, Glipizide, Night",
                "DM Follow, New Co-morbidities",
                "DM Follow, Current use of tobacco",
                "DM Follow, Current use of alcohol",
                "DM Follow, Counselling"],
                disable: ["DM Follow, Medicine dispensed to"]
            }
        }
        else if(result=="No"){

            return{
                disable: ["DM Follow, Height",
                "DM Follow, Weight",
                "DM Follow, BMI",
                "Random Blood Sugar Data",
                "Blood Pressure",
                "DM Follow, Prescribed medications",
                "DM Follow, Has the patient taken todays medicines as instructed",
                "DM Follow, Number of times food is taken in a day",
                "DM Follow, Patient is taking","DM Follow, How many days patient is out of medicines?",
                "DM Follow, Have the patient stopped the medicines?",
                "DM Follow, ADRs",
                "DM Follow, Any cardiac chest pain since the last clinic visit?",
                "DM Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "DM Follow, since last visit, did the patient have weakness on one side of his body?",
                "DM Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "DM Follow, New Co-morbidities",
                "DM Follow, Current use of tobacco",
                "DM Follow, Current use of alcohol",
                "DM Follow, Counselling"],
                enable: ["DM Follow, Rx, Metformin, Morning",
                "DM Follow, Rx, Metformin, Afternoon",
                "DM Follow, Rx, Metformin, Night",
                "DM Follow, Rx, Glipizide, Morning",
                "DM Follow, Rx, Glipizide, Afternoon",
                "DM Follow, Rx, Glipizide, Night",
                "DM Follow, Medicine dispensed to",
                "DM Follow, Days"]
            }

        } 
        else {
            return {
                disable: ["DM Follow, Height",
                "DM Follow, Weight",
                "DM Follow, BMI",
                "Random Blood Sugar Data",
                "Blood Pressure",
                "DM Follow, Prescribed medications",
                "DM Follow, Has the patient taken todays medicines as instructed",
                "DM Follow, Number of times food is taken in a day",
                "DM Follow, Patient is taking",
                "DM Follow, How many days patient is out of medicines?",
                "DM Follow, Have the patient stopped the medicines?",
                "DM Follow, ADRs",
                "DM Follow, Any cardiac chest pain since the last clinic visit?",
                "DM Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "DM Follow, since last visit, did the patient have weakness on one side of his body?",
                "DM Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "DM Follow, Rx",
                "DM Follow, New Co-morbidities",
                "DM Follow, Current use of tobacco",
                "DM Follow, Current use of alcohol",
                "DM Follow, Counselling"]
            }
        }
    },
    'Stroke Follow, Is the patient present?' : function (formName, formFieldValues) {
        var result = formFieldValues['Stroke Follow, Is the patient present?'];
        if (result=="Yes") {
            return {
                enable: [
                "Stroke Follow, Weight",
                "Stroke Follow, Random Blood Sugar Data",
                "Blood Pressure",
                "Stroke Follow, Prescribed medications",
                "Stroke Follow, Has the patient taken todays medicines as instructed",
                "Stroke Follow, Patient is taking",
                "Stroke Follow, How many days patient is out of medicines?",
                "Stroke Follow, ADRs",
                "Stroke Follow, Days",
                "Stroke Follow, Any cardiac chest pain since the last clinic visit?",
                "Stroke Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "Stroke Follow, since last visit, did the patient have weakness on one side of his body?",
                "Stroke Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "Stroke Follow, Rx, Aspirin Morning",
                "Stroke Follow, Rx, Aspirin Afternoon",
                "Stroke Follow, Rx, Aspirin Night",
                "Stroke Follow, Rx, Atorvastatin Morning",
                "Stroke Follow, Rx, Atorvastatin Afternoon",
                "Stroke Follow, Rx, Atorvastatin Night",
                "Stroke Follow, New Co-morbidities",
                "Stroke Follow, Current use of tobacco",
                "Stroke Follow, Current use of alcohol",
                "Stroke Follow, Counselling"],
                disable: ["Stroke Follow, Medicine dispensed to"]
            }
        }
        else if(result=="No"){

            return{
                disable: [
                "Stroke Follow, Weight",
                "Stroke Follow, Random Blood Sugar Data",
                "Blood Pressure",
                "Stroke Follow, Prescribed medications",
                "Stroke Follow, Has the patient taken todays medicines as instructed",
                "Stroke Follow, Patient is taking",
                "Stroke Follow, How many days patient is out of medicines?",
                "Stroke Follow, ADRs",
                "Stroke Follow, Any cardiac chest pain since the last clinic visit?",
                "Stroke Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "Stroke Follow, since last visit, did the patient have weakness on one side of his body?",
                "Stroke Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "Stroke Follow, New Co-morbidities",
                "Stroke Follow, Current use of tobacco",
                "Stroke Follow, Current use of alcohol",
                "Stroke Follow, Counselling"],
                enable: ["Stroke Follow, Rx, Aspirin Morning",
                "Stroke Follow, Rx, Aspirin Afternoon",
                "Stroke Follow, Rx, Aspirin Night",
                "Stroke Follow, Rx, Atorvastatin Morning",
                "Stroke Follow, Rx, Atorvastatin Afternoon",
                "Stroke Follow, Rx, Atorvastatin Night",
                "Stroke Follow, Medicine dispensed to",
                "Stroke Follow, Days"]
            }

        } 
        else {
            return {
                disable: [
                 "Stroke Follow, Weight",
                "Stroke Follow, Random Blood Sugar Data",
                "Blood Pressure",
                "Stroke Follow, Prescribed medications",
                "Stroke Follow, Has the patient taken todays medicines as instructed",
                "Stroke Follow, Patient is taking",
                "Stroke Follow, How many days patient is out of medicines?",
                "Stroke Follow, ADRs",
                "Stroke Follow, Days",
                "Stroke Follow, Any cardiac chest pain since the last clinic visit?",
                "Stroke Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "Stroke Follow, since last visit, did the patient have weakness on one side of his body?",
                "Stroke Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "Stroke Follow, Rx",
                "Stroke Follow, New Co-morbidities",
                "Stroke Follow, Current use of tobacco",
                "Stroke Follow, Current use of alcohol",
                "Stroke Follow, Counselling"]
            }
        }
    },
    'HTN Follow, Is the patient present?' : function (formName, formFieldValues) {
        var result = formFieldValues['HTN Follow, Is the patient present?'];
        if (result=="Yes") {
            return {
                enable: [
                "HTN Follow, Weight",
                "Blood Pressure",
                "HTN Follow, Pulse Data",
                "HTN Follow, Prescribed medications",
                "HTN Follow, Has the patient taken todays medicines as instructed",
                "HTN Follow, Patient is taking",
                "HTN Follow, How many days the patient is out of medicines?",
                "HTN Follow, Have the patient stopped the medication?",
                "HTN Follow, ADRs",
                "HTN Follow, Days",
                "HTN Follow, Any cardiac chest pain since the last clinic visit?",
                "HTN Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "HTN Follow, since last visit, did the patient have weakness on one side of his body?",
                "HTN Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "HTN Follow, Rx, Hydrochlorothiazide Morning",
                "HTN Follow, Rx, Hydrochlorothiazide Afternoon",
                "HTN Follow, Rx, Hydrochlorothiazide Night",
                "HTN Follow, Rx, Amlodipine Morning",
                "HTN Follow, Rx, Amlodipine Afternoon",
                "HTN Follow, Rx, Amlodipine Night",
                "HTN Follow, Rx, Atenolol Morning",
                "HTN Follow, Rx, Atenolol Afternoon",
                "HTN Follow, Rx, Atenolol Night",
                "HTN Follow, New Co-morbidities",
                "HTN Follow, Current use of tobacco",
                "HTN Follow, Current use of alcohol",
                "HTN Follow, Counselling"],
                disable: ["HTN Follow, Medicine dispensed to"]
            }
        }
        else if(result=="No"){

            return{
                disable: ["HTN Follow, Weight",
                "Blood Pressure",
                "HTN Follow, Pulse Data",
                "HTN Follow, Prescribed medications",
                "HTN Follow, Has the patient taken todays medicines as instructed",
                "HTN Follow, Patient is taking",
                "HTN Follow, How many days the patient is out of medicines?",
                "HTN Follow, Have the patient stopped the medication?",
                "HTN Follow, ADRs",
                "HTN Follow, Any cardiac chest pain since the last clinic visit?",
                "HTN Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "HTN Follow, since last visit, did the patient have weakness on one side of his body?",
                "HTN Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "HTN Follow, New Co-morbidities",
                "HTN Follow, Current use of tobacco",
                "HTN Follow, Current use of alcohol",
                "HTN Follow, Counselling"],
                enable: ["HTN Follow, Rx, Hydrochlorothiazide Morning",
                "HTN Follow, Rx, Hydrochlorothiazide Afternoon",
                "HTN Follow, Rx, Hydrochlorothiazide Night",
                "HTN Follow, Rx, Amlodipine Morning",
                "HTN Follow, Rx, Amlodipine Afternoon",
                "HTN Follow, Rx, Amlodipine Night",
                "HTN Follow, Rx, Atenolol Morning",
                "HTN Follow, Rx, Atenolol Afternoon",
                "HTN Follow, Rx, Atenolol Night",
                "HTN Follow, Medicine dispensed to",
                "HTN Follow, Days"]
            }

        } 
        else {
            return {
                disable: ["HTN Follow, Weight",
                "Blood Pressure",
                "HTN Follow, Pulse Data",
                "HTN Follow, Prescribed medications",
                "HTN Follow, Has the patient taken todays medicines as instructed",
                "HTN Follow, Patient is taking",
                "HTN Follow, How many days the patient is out of medicines?",
                "HTN Follow, Have the patient stopped the medication?",
                "HTN Follow, ADRs",
                "HTN Follow, Any cardiac chest pain since the last clinic visit?",
                "HTN Follow, any shortness of breath due to which patient is unable to do household/occupational work?",
                "HTN Follow, since last visit, did the patient have weakness on one side of his body?",
                "HTN Follow, If there was weakness on one side of the body, did it last more than 24 hrs",
                "HTN Follow, Rx",
                "HTN Follow, New Co-morbidities",
                "HTN Follow, Current use of tobacco",
                "HTN Follow, Current use of alcohol",
                "HTN Follow, Counselling"]
            }
        }
    }
};