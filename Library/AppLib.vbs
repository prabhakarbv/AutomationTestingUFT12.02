' ***********************************************************************************************
'
' 						A P P L I C A T I O N      L I B R A  R Y  
'
' ***********************************************************************************************

'1.testCleanUp
'2.invokeBrowser
'3.intLogin
'4.intLogout
'5.clickandNavigate
'6.validateMaxLength
'7.validateEmailFieldMaxLength
'8.validateCommentFieldMaxLength
'9.validateDefaultValue
'10.validateCommentDefaultValue
'11.validateEmailDefaultValue
'12.validatePhoneDefaultValue
'13.validateFaxDefaultValue
'14.objectExistanceCheck
'15.popUpEmailFieldValidation
'16.validateDateFormat
'17.getExcelDataObject
'18.fReadOutLookMail

' ================================================================================================
'  NAME 	: testCleanUp
'  DESCRIPTION 	: This function is used to write the summary part of the report & close all teh browsers.
'  PARAMETERS	:  
' ================================================================================================

Public Function testCleanUp()
	'systemutil.CloseProcessByName("FIREFOX.EXE")
	systemutil.CloseProcessByName("IEXPLORE.EXE")
	systemutil.CloseProcessByName("CHROME.EXE")
	'systemutil.CloseProcessByName("EXCEL.EXE")
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}" & "!\\.\root\cimv2")
	Set colProcess = objWMIService.ExecQuery ("Select * From Win32_Process")
	For Each objProcess in colProcess
		If LCase(objProcess.Name) = LCase("EXCEL.EXE") OR LCase(objProcess.Name) = LCase("EXCEL.EXE *32") Then
			objProcess.Terminate()
			'MsgBox "- ACTION: " & objProcess.Name & " terminated"
		End If
	Next
	TestCaseExecutiveSummary ()
End Function




' ================================================================================================
'  NAME			    : invokeBrowser
'  DESCRIPTION 	  	: This function delete cookies, close previously open browsers and opens the app url
'  PARAMETERS		: 
' ================================================================================================
Function invokeBrowser()
	WebUtil.DeleteCookies 	'Delete cookies
	systemutil.CloseProcessByName("iexplore.exe")
	systemutil.CloseProcessByName("chrome.exe")
	systemutil.CloseProcessByName("firefox.exe")
													
													
	Dim mode_Maximized, mode_Minimized
	mode_Maximized = 3 'Open in maximized mode
	mode_Minimized = 2 'Open in minimized mode
	
	
	If UCASE(strBrowser) = "IE" Then						'open Browser according to XLS sheet
		SystemUtil.Run "iexplore.exe", strURL , , ,mode_Maximized 
	End If
	
	If UCASE(strBrowser) = "CHROME" Then
		SystemUtil.Run "chrome.exe", strURL , , ,mode_Maximized
	End If
	
	If UCASE(strBrowser) = "FIREFOX" Then
		SystemUtil.Run "firefox,.exe", strURL , , ,mode_Maximized
	End If
	
	wait(5)
	Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").Sync
	If Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").Exist(5) Then
		invokeBrowser = true
	Else
		invokeBrowser = false
	End If
End Function







' ============================================================================================================
'  NAME			: intLogin
'  DESCRIPTION 	  	: This function checks if the login page exists and tries to login.Returns 1 is successful
'  PARAMETERS		: 
' ============================================================================================================
Function Login()
	strLoginDataPath = strTestDataPath & Environment.Value("TestName") & ".xlsx"
	DataTable.AddSheet "LogIn"
	DataTable.ImportSheet strLoginDataPath, "LogIn", "LogIn"
	dtUsername = Trim(DataTable.GetSheet("LogIn").GetParameter("UserName").Value)
	dtPassword= Trim( DataTable.GetSheet("LogIn").GetParameter("Password").Value)
	sUsername = dtUsername
	sPassword = dtPassword
	Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").Sync
	If Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").Exist(6) Then
        Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").WebEdit("txt_userName").Set sUsername
        Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").WebEdit("txt_password").Set sPassword
        Browser("Welcome: Mercury Tours").Page("Welcome: Mercury Tours").Image("btn_Sign-In").Click
        Reporter.ReportEvent micPass,1 ,"Login page appeared, credentials entered"
		LogResult micPass , "Login Page Should Appear" , "Login Page appeared Successfully"   
    Else
    	Reporter.ReportEvent micFail, "Login Page Should Appear" ,"Login page did NOT Appeared"
    	LogResult micFail , "Login Page Should Appear" , "Login page did NOT Appeared"
    	testCleanUp()
 		ExitTest
	End If
End Function



' ================================================================================================
'  NAME			: intLogout
'  DESCRIPTION 	  	: This function click on logout button and checks if the page logs out.
'  PARAMETERS		: 
' ================================================================================================
Function intLogout()

End Function

'================================================================================================
'Function Name		  :	clickAndNavigate
'Function Description : This function is used to Click on the required object and then verify the required navigation page on a given web page											
'Parameters	          : strClickObjName - 			Name of the Object to Click (String type)
'  				  		strPageName - 				Name Of the Page we are getting navigated (String type)
'				  		objToClick - 				Object To Click 
'				  		objChkAfterNavigation - 	Object Existance to be Validated After Navigation
' ================================================================================================
Function clickAndNavigate(strPageName,strClickObjName,objToClick,objChkAfterNavigation)

	If objToClick.Exist(5) Then
		objToClick.Click
		If objChkAfterNavigation.Exist(5) Then
			LogResult micPass, "User should be navigated to " & strPageName & " page ", "User navigated to " & strPageName & " page"
		Else
			LogResult micFail, "User should be navigated to " & strPageName & " page", "User not navigated to " & strPageName & "page" & VbcrLf & " - Exit test execution"
			testCleanUp()
			ExitTest
		End if	
	Else
		LogResult micFail, strClickObjName & " is not available", "User not navigated to " & strPageName & " page" & VbcrLf & " -Test Execution Terminating"
		testCleanUp()
		ExitTest
	End If
	
	Set strPageName = Nothing
	Set strClickObjName = Nothing
	Set objToClick = Nothing
	Set objChkAfterNavigation = Nothing

End Function

' ================================================================================================
'  NAME         : validateMaxLength
'  DESCRIPTION  : This function is used to validate the maximum length for Web Edit                                                                                                       
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name, 
'				  strExpectedMaxLength - Maximum length which user want to enter
' ================================================================================================
Public Function validateMaxLength(objPage, strObjectName, strExpectedMaxLength)
	MaxLen = objPage.WebEdit(strObjectName).GetROProperty("max length")
	If  MaxLen = strExpectedMaxLength Then
		LogResult micPass, "Validate Field Maximum Length", "Maximum Length does match as '"& MaxLen &"' for " & strObjectName
	Else
		LogResult micFail, "Validate Field Maximum Length", "Maximum Length does not match as '" & MaxLen &  "' for " & strObjectName
	End If
End Function

' ================================================================================================
'  NAME         : validateEmailFieldMaxLength
'  DESCRIPTION  : This function is used to validate the maximum length for Email Fields Max Length                                                                                                       
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name, 
' ================================================================================================
Public Function validateEmailFieldMaxLength(objPage, strObjectName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	strExpectedMaxLength = fieldPropertiesObj.Cells(3,1).value                       ' Cells(3,1) = Email_MaxLength 
	validateMaxLength objPage, strObjectName, strExpectedMaxLength
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : validateCommentFieldMaxLength
'  DESCRIPTION  : This function is used to validate the maximum length for Email Fields Max Length                                                                                                       
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name, 
' ================================================================================================
Public Function validateCommentFieldMaxLength(objPage, strObjectName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	strExpectedMaxLength = fieldPropertiesObj.Cells(3,2).value                       ' Cells(3,2) = Comment_MaxLength 
	validateMaxLength objPage, strObjectName, strExpectedMaxLength
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : validateDefaultValue
'  DESCRIPTION  : This function is used to validate the default value for any Web Edit                                                                                                       
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name, 
'				  strExpectedValue - Default Value that user should just on clicking the field
' ================================================================================================
Public Function validateDefaultValue(objPage, strObjectName, strExpectedValue)
	objPage.WebEdit(strObjectName).click
	strDefaultValue = objPage.WebEdit(strObjectName).GetROProperty("value")
	If  strDefaultValue = strExpectedValue Then
		LogResult micPass, "Validate Field Default Value", "Default Value does match as  '"& strDefaultValue &"' for " & strObjectName
	Else
		LogResult micFail, "Validate Field Default Value", "Default Value does NOT match as '" & strDefaultValue &  "' for " & strObjectName
	End If
End Function

' ================================================================================================
'  NAME         : validateCommentDefaultValue
'  DESCRIPTION  : This function is used to validate the default value for any Comment                                                                                                      
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name
' ================================================================================================
Public Function validateCommentDefaultValue(objPage, strObjectName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	strExpectedDefaultValue = fieldPropertiesObj.Cells(6,1).value                       ' Cells(6,1) = Comment_DefaultValue
	validateDefaultValue objPage, strObjectName, strExpectedDefaultValue
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : validateEmailDefaultValue
'  DESCRIPTION  : This function is used to validate the default value for any Comment                                                                                                      
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name
' ================================================================================================
Public Function validateEmailDefaultValue(objPage, strObjectName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	strExpectedDefaultValue = fieldPropertiesObj.Cells(6,2).value                       ' Cells(6,2) = Email_DefaultValue
	validateDefaultValue objPage, strObjectName, strExpectedDefaultValue
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : validatePhoneDefaultValue
'  DESCRIPTION  : This function is used to validate the default value for any Phone No.                                                                                                       
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name
' ================================================================================================
Public Function validatePhoneDefaultValue(objPage, strObjectName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	strExpectedDefaultValue = fieldPropertiesObj.Cells(6,3).value                       ' Cells(6,3) = Phone_DefaultValue
	validateDefaultValue objPage, strObjectName, strExpectedDefaultValue
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : validateFaxDefaultValue
'  DESCRIPTION  : This function is used to validate the default value for any Fax                                                                                                    
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - WebEdit Logical name
' ================================================================================================
Public Function validateFaxDefaultValue(objPage, strObjectName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	strExpectedDefaultValue = fieldPropertiesObj.Cells(6,4).value                       ' Cells(6,4) = Fax_DefaultValue
	validateDefaultValue objPage, strObjectName, strExpectedDefaultValue
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : objectExistanceCheck
'  DESCRIPTION  : This function is used to check the existance of a Object in a Page                                                                                                    
'  PARAMETERS   : objPage - Page Object, 
'				  objObject - Web Object 
'				  strPageName - Logical Display Name of the Page
'				  strObjectName - Logical Display Name of the Object
' ================================================================================================
Public Function objectExistanceCheck(objPage, objObject , strPageName , strObjectName)
	objPage.sync
	objObject.highlight
	If objObject.Exist(2) Then
		LogResult micpass , UCASE(strObjectName) & " should be Found in the page " & UCASE(strPageName) , UCASE(strObjectName) & " is Found"
	Else
		LogResult micFail , UCASE(strObjectName) & " should be Found in the page " & UCASE(strPageName) , UCASE(strObjectName) & " is NOT Found"
	End If
End Function

' ================================================================================================
'  NAME         : popUpEmailFieldValidation
'  DESCRIPTION  : This function is used to check "Validation Regex" and Validation Message for Email field                                                                                                   
'  PARAMETERS   : objPage - Page Object, 
'				  strObjectName - Web Edit logical Name
' ================================================================================================
Public Function popUpEmailFieldValidation(objPage, strObjectName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	Browser("CIT Leases").Page("MissingInvoiceRequestPage").WebList("List_BoxInvoiceCopy").Select "Email"

	'-----------------------------Validate 'Validation Messages'-----------------------' 14 - data 13 - message 12 - heaeder
	For Iterator = 2 To 15 Step 1
		If fieldPropertiesObj.Cells(12,Iterator).value <> "" Then
			objPage.WebEdit(strObjectName).click
			data = fieldPropertiesObj.Cells(14,Iterator).value
			objPage.WebEdit(strObjectName).Set data
			objPage.WebEdit(strObjectName).highlight
			Browser("CIT Leases").Page("MissingInvoiceRequestPage").WebList("List_BoxInvoiceCopy").MiddleClick
			If Iterator = 2  Then
				If  Browser("CIT Leases").Page("MissingInvoiceRequestPage").WebElement("Lbl_EmailAddressIsRequired").GetROProperty("innertext")= fieldPropertiesObj.Cells(13,Iterator).value Then
					LogResult micpass , "Validation Message check for Blank Email Address :" & fieldPropertiesObj.Cells(14,Iterator).value  , "'" & fieldPropertiesObj.Cells(13,Iterator).value &"'- successfully shown"
				Else
					LogResult micfail , "Validation Message check for Blank Email Address :" & fieldPropertiesObj.Cells(14,Iterator).value , "Valid Message Failed to show"
				End If
			Else
				If (Browser("CIT Leases").Page("MissingInvoiceRequestPage").WebElement("Lbl_PleaseEnterValidEmail").GetROProperty("visible")= "True") AND (Browser("CIT Leases").Page("MissingInvoiceRequestPage").WebElement("Lbl_PleaseEnterValidEmail").GetROProperty("innertext")= fieldPropertiesObj.Cells(13,Iterator).value) Then
					LogResult micpass , "Validation Message check for Invalid Email Address :" & fieldPropertiesObj.Cells(14,Iterator).value , "Invalid due to '"  & fieldPropertiesObj.Cells(15,Iterator).value &"'- successfully verified"
				Else
					LogResult micfail , "Validation Message check for Invalid Email Address :" & fieldPropertiesObj.Cells(14,Iterator).value, "Valid Message Failed to show"
				End If
			End If
		Else	
			Exit For
		End If
	Next
	
	'---------------------------------Validate Regular Expression---------------------' July 18 2017 , Regular Expression validation commented as we are not sure with the expected Regex
'	strExpectedDefaultValue = fieldPropertiesObj.Cells(9,1).value                       ' Cells(9,1) = Email_Regex
'	If INSTR(objPage.WebEdit(strObjectName).GetRoProperty("outerhtml") , strExpectedDefaultValue ) <> 0 Then
'		LogResult micpass , "Email Field Validation for " & strObjectName , " Validation Successful with " & strExpectedDefaultValue
'	Else
'		LogResult micfail , "Email Field Validation for " & strObjectName , " Validation UN-Successful with " & strExpectedDefaultValue
'	End If
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : validateDateFormat
'  DESCRIPTION  : This function is used to validate the date format of any field                                                                                                    
'  PARAMETERS   : objObject - Date Object
' ================================================================================================
Public Function validateDateFormat(objObject)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	Set controllerExcel = objExcel.Workbooks.Open( strContPath ) 
	Set fieldPropertiesObj = controllerExcel.Sheets("FieldProperties")
	strDateFormat = fieldPropertiesObj.Cells(17,1).value                       ' Cells(6,4) = Fax_DefaultValue
	strDate = objObject.GetROProperty("outertext")
	arrDate = SPLIT(strDate , "/")
	
	If UCASE(strDateFormat)="MM/DD/YY" Then
		IF (arrDate(0) <= 12) AND (arrDate(1) <= 31) AND ( arrDate(2) \ 100 = 0)   Then
			LogResult micpass , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		Else
			LogResult micfail , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		End If
	ElseIf UCASE(strDateFormat)="DD/MM/YY" Then
		IF (arrDate(0) <= 31) AND (arrDate(1) <= 12) AND ( arrDate(2) \ 100 = 0)   Then
			LogResult micpass , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		Else
			LogResult micfail , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		End If
	ElseIf UCASE(strDateFormat)="DD/MM/YYYY"  Then
		IF (arrDate(0) <= 31) AND (arrDate(1) <= 12) AND ( arrDate(2) \ 10000 = 0)   Then
			LogResult micpass , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		Else
			LogResult micfail , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		End If
	ElseIf UCASE(strDateFormat)="MM/DD/YYYY" Then
		IF (arrDate(0) <= 12) AND (arrDate(1) <= 31) AND ( arrDate(2) \ 10000 = 0)   Then
			LogResult micpass , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		Else
			LogResult micfail , "Date should be in this format : " & strDateFormat , "Date is : " & strDate  
		End If
	End If
	
	Set fieldPropertiesObj = nothing
	controllerExcel.close
	Set controllerExcel = nothing
	objExcel.quit
	Set objExcel = nothing
	systemutil.CloseProcessByName("EXCEL.EXE")
End Function

' ================================================================================================
'  NAME         : getExcelDataObject
'  DESCRIPTION  : This function is used to get the excel object of the Test Case itself.                                                                                                
'  PARAMETERS   : sheetName - Data Object
' ================================================================================================
Public Function getExcelDataObject(strSheetName)
	Set objExcel = CreateObject("Excel.Application") 
	objExcel.Visible = False
	strLoginDataPath = strTestDataPath & Environment.Value("TestName") & ".xlsx"
	Set dataWorkbook = objExcel.Workbooks.Open( strLoginDataPath ) 
	Set excelDataObject = dataWorkbook.Sheets(strSheetName)
	Set getExcelDataObject = excelDataObject
End Function


' ================================================================================================
'  NAME				: fReadOutLookMail
'  DESCRIPTION		: The function reads the OutLook mail and outputs the body and sender of the email
'  PARAMETERS		: 
' ================================================================================================
Public Function fReadOutLookMail (sSubject, sMailBody , sSender)
   	CAPTURE_ERROR_SCREENSHOT = False
	fReadOutLookMail = False
	On Error Resume Next
	Dim Member_Number,Username,Password,InBoxFlag , MailFound	
	MailFound  = 0	
	InboxFlag = 0				'Flag to indicate if there exists unread emails in the Inbox or not
	olFolderInbox = 6			'6 indicates the folder is Inbox. If you want to change the folder, need to change the value to corresponding folder value.
	Set myOlApp = CreateObject("Outlook.Application")
	Set myNameSpace = myOlApp.GetNameSpace("MAPI") ''Messaging Application Programming Interface (MAPI)
	Set myInBox= myNameSpace.GetDefaultFolder(olFolderInbox)
	Set InBoxItems = myInBox.Items

	If (Err.Description <> "") Then
		LogResult micFail, "Outlook Application", "Unable to open Outlook Application"
		On Error Goto 0
		Exit Function
	End If
	Flag = 0
	Counter = 0
	
	''Do while Flag = 0 AND Counter < 50
	Do while Flag = 0 AND Counter < 10
		For each mailobject in InBoxItems		'For all emails in the inbox folder
			If mailobject.unread Then
				InboxFlag = InboxFlag + 1		'Increment unread emails flag
				mailsubject = mailobject.subject
				If Instr(1, Trim(mailsubject), Trim(sSubject)) > 0 Then
					sMailBody = Trim(mailobject.body)
					sSender = mailobject.sendername
					fReadOutLookMail = True
					MailFound = 1
					mailobject.unRead = False		'Mark the unread email as Read
				End If
			Else								'If Email is read, dont increment the unread emails flag
				InBoxFlag = InboxFlag + 0
			End If
		Next
		If fReadOutLookMail = True Then
			Flag = 1
		Else
			Counter = Counter +1
			Wait(5)
		End If
	Loop
	
	'If The Unread emails flag is still 0 then report error as no emails received.
	If MailFound = 0 Then
		LogResult micFail, "Read OutLook Mail", "No new email exist in Outlook with the subject '" & sSubject & "'"
		fReadOutLookMail = False
		testCleanUp()
 		ExitTest
    Else
		LogResult micPass, "Read OutLook Mail", "New Email exist in Outlook with the subject '" & sSubject & "'"	    
	End If
	CAPTURE_ERROR_SCREENSHOT = True 
End Function

'================================================================================================
'  NAME                        : Pagination
'  DESCRIPTION  : It will act in the web table and will confirm, 
''''Synatx w    : objPage.u_Pagination(1)  Here, 1 is for 1st table. So if u need to do the pagination for 2nd table, then put 2 there
'a-	If we select any specific page, then it is navigating to that page or not.
'b-	If we go o last page, the next button (>) is disabled or not.
'c-	In the first page, the previous button (<) is disables or not.
'd-	If we will  put the entire records number in View per page web edit, it is showing all the records in a single field or not.
' 
'  PARAMETERS           :           objPage = ContractPage, 
' ================================================================================================
Public Function Pagination()
	
End Function
