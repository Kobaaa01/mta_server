local browser = nil

-- Otwieranie interfejsu 
function openATMInterface()
    if not browser then
        browser = guiCreateBrowser(0.3, 0.3, 0.4, 0.4, true, true, true)
        addEventHandler("onClientBrowserCreated", browser, function()
            loadBrowserURL(source, "http://mta/local/atm.html")  
        end)
    else
        guiSetVisible(browser, true)  
    end
    showCursor(true)  
end
addEvent("openATMInterface", true)
addEventHandler("openATMInterface", root, openATMInterface)

-- Zamykanie interfejsu
function closeATMInterface()
    if browser then
        guiSetVisible(browser, false)  
    end
    showCursor(false)  
end
addEvent("closeATMInterface", true)
addEventHandler("closeATMInterface", root, closeATMInterface)

function requestTransfer(targetNickname, amount)
    triggerServerEvent("transferMoney", localPlayer, localPlayer, targetNickname, amount)
end

addEvent("requestTransfer", true)
addEventHandler("requestTransfer", root, requestTransfer)

function closeFromHTML()
    closeATMInterface()
end
addEvent("closeFromHTML", true)
addEventHandler("closeFromHTML", root, closeFromHTML)

function requestWithdraw(amount)
    triggerServerEvent("withdrawMoney", localPlayer, localPlayer, amount)
end
addEvent("requestWithdraw", true)
addEventHandler("requestWithdraw", root, requestWithdraw)

function requestDeposit(amount)
    triggerServerEvent("depositMoney", localPlayer, localPlayer, amount)
end
addEvent("requestDeposit", true)
addEventHandler("requestDeposit", root, requestDeposit)