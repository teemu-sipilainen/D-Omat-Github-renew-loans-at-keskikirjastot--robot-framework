*** Settings ***
Library    Browser

*** Keywords ***
Setup Browser
    [Arguments]    ${browser}=chromium    ${headless}=true    ${slowMo}=0:00:00.5
    ...            ${viewport}={"width": 1366, "height": 768}    ${url}=https://keski.finna.fi/
    New Browser    browser=${browser}    headless=${headless}    slowMo=${slowMo}
    New Context    viewport=${viewport}
    New Page       url=${url}