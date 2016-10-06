Bahmni.ConceptSet.FormConditions.rules = {
    'Diastolic Data' : function (formName, formFieldValues) {
        var systolic = formFieldValues['Systolic'];
        var diastolic = formFieldValues['Diastolic'];
        if (systolic || diastolic) {

            return {
                enable: ["Posture"]
            }
        } else {
            return {
                disable: ["Posture"]
            }
        }
    },
    'Systolic Data' : function (formName, formFieldValues) {
        var systolic = formFieldValues['Systolic'];
        var diastolic = formFieldValues['Diastolic'];
        if (systolic || diastolic) {

            return {
                enable: ["Posture"]
            }
        } else {
            return {
                disable: ["Posture"]
            }
        }
    },
    'DM Follow, ADRs' : function (formName, formFieldValues) {
        var result = formFieldValues['DM Follow, ADRs'];
        if (result == "SAE") {
            return {
                enable: ["DM Follow, SAE description"]
            }
        } else {
            return {
                disable: ["DM Follow, SAE description"]
            }
        }
    },
    'HTN Follow, ADRs' : function (formName, formFieldValues) {
        var result = formFieldValues['HTN Follow, ADRs'];
        if (result == "SAE") {
            return {
                enable: ["HTN Follow, SAE description"]
            }
        } else {
            return {
                disable: ["HTN Follow, SAE description"]
            }
        }
    },
    'Stroke Follow, ADRs' : function (formName, formFieldValues) {
        var result = formFieldValues['Stroke Follow, ADRs'];
        if (result == "SAE") {
            return {
                enable: ["Stroke Follow, SAE description"]
            }
        } else {
            return {
                disable: ["Stroke Follow, SAE description"]
            }
        }
    }
};