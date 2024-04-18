// Load Active Admin's styles into Webpacker,
// see `active_admin.scss` for customization.
import "../stylesheets/active_admin";

import "@activeadmin/activeadmin";

// show/hide interaction panels
$(document).ready(function(){
  // button ids
  const questionButtonId = 'question_interaction_button';
  const expertCallButtonId = 'expert_call_interaction_button';
  const expertCall11ButtonId = 'expert_call_1_1_interaction_button';
  const expertCall15ButtonId = 'expert_call_1_5_interaction_button';
  // panels ids
  const questionPanel = 'questions_interactions';
  const expertCallPanel = 'expert_calls_interactions';
  const expertCall11Panel = 'expert_calls_interactions_1_1';
  const expertCall15Panel = 'expert_calls_interactions_1_5';
  // get show buttons
  const questionButton = document.getElementById(questionButtonId);
  const expertCallButton = document.getElementById(expertCallButtonId);
  const expertCall11Button = document.getElementById(expertCall11ButtonId);
  const expertCall15Button = document.getElementById(expertCall15ButtonId);

  const buttonsArray = [questionButton, expertCallButton, expertCall11Button, expertCall15Button]
  const panelIdsArray = [questionPanel, expertCallPanel, expertCall11Panel, expertCall15Panel]
  function showPanelEvent(panelId, button){
    const panel = document.getElementById(panelId);
    if (panel == null){
      return;
    }
    if (button.textContent === 'Show'){
      button.textContent = 'Hide'
    } else {
      button.textContent = 'Show'
    }
    if (panel.style.display === 'none' || panel.style.display === '') {
      panel.style.display = 'block';
    } else {
      panel.style.display = 'none';
    }
  }
  for(let i = 0; i <= buttonsArray.length; i++){
    if (buttonsArray[i] == null){
      continue;
    }
    buttonsArray[i].onclick = function() {showPanelEvent(panelIdsArray[i], buttonsArray[i])};
  }
})