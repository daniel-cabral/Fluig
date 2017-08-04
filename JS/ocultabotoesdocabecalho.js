 //Oculta Botõe do Processo
 window.parent.$('#wcm_widget').find("[data-save]").css("text-decoration","line-through");
 window.parent.$('#wcm_widget').find("[data-save]").hide("data-save");
 window.parent.$('#wcm_widget').find("[data-back]").css("text-decoration","line-through");
 window.parent.$('#wcm_widget').find("[data-back]").hide("data-back");
 window.parent.$("#textActivity").toggle();
 
 window.parent.$('#page-header').hide();
 window.parent.$("#workflowView-cardViewer").css("margin-top","-170px");