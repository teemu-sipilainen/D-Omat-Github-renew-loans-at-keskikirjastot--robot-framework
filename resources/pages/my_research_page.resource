*** Settings ***
Library      DateTime
Library      Browser
Library      BuiltIn
Library      Collections
Library      String
Variables    locators${/}my_research_page.yaml

*** Variables ***
${TABLE_SELECTOR}        table.myresearch-table
${TABLE_ROW_SELECTOR}    table.myresearch-table tr[id^="recordkeski."]
# xpath://tr[contains(@class, 'myresearch-row')]
${DAYS_TO_EXPIRE}        10
${DUE_DATE_PATTERN}      Eräpäivä:\s*(\d{1,2}\.\d{1,2}\.\d{4})
${DUE_DATE_PREFIX}       Eräpäivä: 

*** Keywords ***
Renew Loans
    ${rows}=    Get Elements    //tr[starts-with(@id, 'recordkeski') and contains(@class, 'myresearch-row')]
    Log    len(${rows})
    FOR    ${index}    IN RANGE    0    len(${rows})
        ${row}=    Get Element    //tr[starts-with(@id, 'recordkeski') and contains(@class, 'myresearch-row')][${index + 1}]
        ${due_date_text}=    Get Text    ${row}//td[@class="checkedout-status-information"]//strong[contains(text(), 'Eräpäivä')]
        Log    Due Date Text: ${due_date_text}
        
        # Tarkistetaan, että due_date_text ei ole tyhjä
        Run Keyword If    '${due_date_text}' == ''    Fail    Eräpäiväteksti on tyhjä rivillä ${index + 1}
        
        # Poistetaan alusta "Eräpäivä: "
        ${due_date_string}=    Remove String    ${due_date_text}    ${DUE_DATE_PREFIX}
        Log    After Removing Prefix: ${due_date_string}
        
        # Poistetaan mahdolliset välilyönnit
        ${due_date_string}=    Strip String    ${due_date_string}
        Log    Due Date String (Stripped): ${due_date_string}
        
        # Muutetaan päivämäärä
        ${due_date}=    Convert Date    ${due_date_string}    result_format=%Y-%m-%d    date_format=%d.%m.%Y
        Log    Converted Due Date: ${due_date}
        
        ${current_date}=    Get Current Date    result_format=%Y-%m-%d
        Log    Current Date: ${current_date}
        
        # Lasketaan ero päivämääristä
        ${difference}=    Evaluate    (datetime.datetime.strptime('${due_date}', '%Y-%m-%d') - datetime.datetime.strptime('${current_date}', '%Y-%m-%d')).days    datetime
        Log    Difference in Days: ${difference}
        
        # Valitaan checkbox, jos ero on alle 2 päivää
        Run Keyword If    ${difference} < ${DAYS_TO_EXPIRE}    Click    ${row}//td[@class="text-left checkbox-col"]//input[@type="checkbox"]
    END

Renew Loans 2
    Wait For Elements State    ${TABLE_SELECTOR}    visible

    ${rows}=    Get Elements    table.myresearch-table tr[id^="recordkeski."]
    FOR    ${row}    IN    @{rows}
        ${row_id}=    Get Attribute    ${row}    id
        ${number}=    Evaluate    re.search(r'\\d+', "${row_id}").group(0)    re
        Log    ${number}
        
        # Etsi eräpäivä
        ${due_date_element}=    Get Element    ${row}    xpath=.//div[@class="status-column"]//strong
        ${due_date_text}=    Get Text    ${due_date_element}
        Log    ${due_date_text}

        # Poista "Eräpäivä:"-teksti ja analysoi päivämäärä
        ${due_date}=    Evaluate    "${due_date_text}".replace("Eräpäivä: ", "")    # Poistaa "Eräpäivä: " osan
        ${due_date}=    Evaluate    datetime.datetime.strptime("${due_date}", "%d.%m.%Y")    datetime

        # Laske ero nykyhetkeen
        ${today}=    Evaluate    datetime.datetime.now()    datetime
        ${time_diff}=    Evaluate    (${due_date} - ${today}).days    datetime

        # Jos eräpäivään on alle 2 vuorokautta, valitaan checkbox
        Run Keyword If    ${time_diff} <= 2    Click    ${row}    xpath=.//input[@type="checkbox" and contains(@class, "checkbox-select-item")]

    END

############################################################

Renew Loans 1
    Wait For Elements State    ${TABLE_SELECTOR}    visible

    ${rows}=    Get Elements    table.myresearch-table tr[id^="recordkeski."]
    FOR    ${row}    IN    @{rows}
        ${row_id}=    Get Attribute    ${row}    id
        ${number}=    Evaluate    re.search(r'\\d+', "${row_id}").group(0)    re
        Log    ${number}
    END

############################################################

Test 1
    ${rows}=    Get Elements    ${TABLE_ROW_SELECTOR}
    FOR    ${row}    IN    @{rows}
        Log    ${rows}
        ${text}=    Get Text    ${row}
        Log    ${text}
    END

Test 2
    ${rows_dollar} =    Get Elements    ${TABLE_ROW_SELECTOR}
    @{rows_at} =    Get Elements    ${TABLE_ROW_SELECTOR}
    Log    ${rows_dollar}
    # Log    @{rows_dollar}
    Log    ${rows_at}
    # Log    @{rows_at}

############################################################

Renew Loans TEMP
    Wait For Elements State    ${TABLE_SELECTOR}    visible
    
    ${rows}=    Get List Of Rows With Upcoming Due Date TEMP
    FOR    ${row}    IN    @{rows}
        Select Checkbox And Click Renew TEMP    ${row}
    END

Get List Of Rows With Upcoming Due Date TEMP
    ${rows}=    Get Elements    xpath=//table[@class="myresearch-table"]//tr[starts-with(@id, 'recordkeski')]
    Log    ${rows}
    ${due_rows}=    Create List
    FOR    ${row}    IN    @{rows}
        Log    ${row}
        ${due_date}=    Get Due Date From Row TEMP    ${row}
        ${current_date}=    Get Current Date    result_format=datetime
        ${time_difference}=    Subtract Date From Date    ${due_date}    ${current_date}
        Run Keyword If    ${time_difference.days} <= ${DAYS_TO_EXPIRE}    Append To List    ${due_rows}    ${row}
    END
    RETURN    ${due_rows}

Get Due Date From Row TEMP
    [Arguments]    ${row}
    Log    ${row}
    ${row_element}=    Get Element    ${row}    # Tämä palauttaa Web-elementin, joka on ${row}
    Log    ${row_element}
    ${due_date_element}=    Get Element    xpath=${row_element}//td[contains(text(), 'Eräpäivä:')]
    Log    Due date element: ${due_date_element}  # Tämä tulostaa löydetyn elementin
    ${due_date_text}=    Get Text    ${due_date_element}   # Haetaan elementin teksti
    ${due_date_text}=    Replace String    ${due_date_text}    Eräpäivä:    ""    # Poistetaan "Eräpäivä:"-teksti
    ${due_date}=    Convert Date    ${due_date_text}    result_format=datetime    date_format=%d.%m.%Y
    RETURN    ${due_date}

Select Checkbox And Click Renew TEMP
    [Arguments]    ${row}
    ${checkbox}=    Get Element    xpath=${row}//input[@class='checkbox-select-item']
    Click    ${checkbox}
    Wait For Elements State    xpath=//input[@id='renewSelected']    visible
    # Click    xpath=//input[@id='renewSelected']
