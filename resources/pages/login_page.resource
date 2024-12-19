*** Settings ***
Library      Browser
Library      utils${/}env_lib.py
Variables    locators${/}login_page.yaml

*** Keywords ***
Fill Login Form And Submit
    Fill Text      ${library_card_number_input}    %{LIBRARY_CARD_NUMBER}
    Fill Secret    ${pin_code_input}    %PIN_CODE
    Click          ${login_page_login_button}