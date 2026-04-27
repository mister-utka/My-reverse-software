.386
.model flat,stdcall
option casemap:none

include StopChildProc.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
	mov		CommandLine,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,IDM_MENU
	mov		wc.lpszClassName,offset ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_DIALOG,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL hThread:HANDLE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hWin
		pop		hWnd
		
		;Настраиваем шрифт
		invoke CreateFont, 16, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH or FF_DONTCARE, addr pszFntName
        mov hFont, eax
        
        ;Применяем шрифты к дочерним окнам
        invoke GetDlgItem, hWin, IDC_BTN_FREEZ
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_BTN_RUN
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
	
        invoke GetDlgItem, hWin, IDC_EDT_GET_NAME_PROC
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_EDT_SEND_INFO_PROC
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_TEXT_INFO_GET_PROC
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_TEXT_INFO_FREZ_PROC
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_EDT_SEARCH_FREQUENCY
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_TEXT_SEARCH_FREQUENCY
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_EDT_DELAY_AFTER_DETECTION
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        invoke GetDlgItem, hWin, IDC_TEXT_DELAY_AFTER_DETECTION
        invoke SendMessage, eax, WM_SETFONT, hFont, TRUE
        
        ;Делаем кнопку Running неактивной
        invoke GetDlgItem, hWin, IDC_BTN_RUN
        invoke EnableWindow, eax, FALSE
        
        ;Заполняем поля задержек
        invoke SetDlgItemText, hWin, IDC_EDT_SEARCH_FREQUENCY, addr pszZero
        invoke SetDlgItemText, hWin, IDC_EDT_DELAY_AFTER_DETECTION, addr pszZero
        
        ;Отображаем окно программы
        invoke EnableWindow, IDC_BTN_RUN, FALSE
        
	.elseif eax==WM_COMMAND
		
		;Обработка кнопок меню
		mov		eax,wParam
		and		eax,0FFFFh
		
		.if eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		.endif	
		
		;Обработка кнопок окна
		mov 	edx, wParam
		movzx	eax, dx
		shr		edx, 16
			
		.if edx==BN_CLICKED
		
			.if eax==IDC_BTN_FREEZ
			
				;Проверяем, что было введено имя процесса
				invoke GetDlgItemText, hWin, IDC_EDT_GET_NAME_PROC, addr buffer, 512
				.if eax==0
					invoke MessageBox, hWin, addr pszInpurProcErr, addr pszError, MB_ICONWARNING
					ret
				.endif
			
				;Получаем задержку в мс, а так же проверяем ввод на корректность
				invoke GetDlgItemText, hWin, IDC_EDT_SEARCH_FREQUENCY, addr SearchFrequency, 9
				invoke CheckNumImput, hWin, addr SearchFrequency
				.if eax==1
					ret
				.endif
				
				;Получаем задержку после обнаружения в мс, а так же проверяем ввод на корректность
				invoke GetDlgItemText, hWin, IDC_EDT_DELAY_AFTER_DETECTION, addr DelayAfterDetection, 9
				invoke CheckNumImput, hWin, addr DelayAfterDetection
				.if eax==1
					ret
				.endif
				
				;Делаем кнопку Running активной
        		invoke GetDlgItem, hWin, IDC_BTN_RUN
        		invoke EnableWindow, eax, TRUE
        		;Делаем кнопку Freezing неактивной
        		invoke GetDlgItem, hWin, IDC_BTN_FREEZ
        		invoke EnableWindow, eax, FALSE
        		;Делаем поле ввода имени процесса неактивным
        		invoke GetDlgItem, hWin, IDC_EDT_GET_NAME_PROC
        		invoke EnableWindow, eax, FALSE
        		;Делаем поле ввода SearchFrequency неактивным
        		invoke GetDlgItem, hWin, IDC_EDT_SEARCH_FREQUENCY
        		invoke EnableWindow, eax, FALSE
        		;Делаем поле ввода DelayAfterDetection неактивным
        		invoke GetDlgItem, hWin, IDC_EDT_DELAY_AFTER_DETECTION
        		invoke EnableWindow, eax, FALSE
				
				;Устанавливаем флаг работы потока заморозки в True-активный
				mov flagThreadSearchProc, 1
				
				;Запускаем поток с бесконечным циклом поиска и замороки
				invoke CreateThread, NULL, 0, addr RunThreadSearchProc, hWnd, 0, NULL
				mov hThread, eax
				
			.elseif eax==IDC_BTN_RUN
				
				;Останавливаем поток
				mov flagThreadSearchProc, 0
				invoke Sleep, 2000
				invoke CloseHandle, hThread
				
				;Делаем кнопку Running неактивной
        		invoke GetDlgItem, hWin, IDC_BTN_RUN
        		invoke EnableWindow, eax, FALSE
        		;Делаем кнопку Freezing активной
        		invoke GetDlgItem, hWin, IDC_BTN_FREEZ
        		invoke EnableWindow, eax, TRUE
        		;Делаем поле ввода имени процесса активным
        		invoke GetDlgItem, hWin, IDC_EDT_GET_NAME_PROC
        		invoke EnableWindow, eax, TRUE
        		;Делаем поле ввода SearchFrequency активным
        		invoke GetDlgItem, hWin, IDC_EDT_SEARCH_FREQUENCY
        		invoke EnableWindow, eax, TRUE
        		;Делаем поле ввода DelayAfterDetection активным
        		invoke GetDlgItem, hWin, IDC_EDT_DELAY_AFTER_DETECTION
        		invoke EnableWindow, eax, TRUE
        		
        		;Пробуем разморозить процессы
        		invoke GetSearchProc, hWin
        		
			.endif	
			
		.endif
		
	.elseif eax==WM_SIZE
		;Надо доделать изменение размера дочерних окон
	
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
		
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
		;Закрываем хендл шрифта
		invoke DeleteObject, hFont
		
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

RunThreadSearchProc proc uses ebx edx ecx esi edi hWin:HWND
	
	;Цикл продолжается, пока флаг выставлен в True(1)
	.while flagThreadSearchProc
		invoke GetSearchProc, hWin
		
		;Задержка перед каждым проходом
		;Преобразовываем Ascii строку в число
		invoke atodw, addr SearchFrequency
		invoke Sleep, eax
	.endw
	
	;Заполняем нулями
	invoke RtlZeroMemory, addr buffer, sizeof buffer
	;Очищаем окно
	invoke SetDlgItemText, hWin, IDC_EDT_SEND_INFO_PROC, addr buffer
	
	xor eax, eax
	ret
	
RunThreadSearchProc endp

CheckNumImput proc uses ebx edx ecx esi edi hWin:HWND, ChekingSting:DWORD

	;Проверка на то, что было введенно число
	mov esi, ChekingSting
	check_num_loop:
		mov al, [esi]		;Берем символ по индексу
		test al, al			;Проверяем на конец строки
		jz check_num_len	;Если дошли до конца строки
		cmp al, '0'			;Проверяем текущий символ, меньше ли он нуля
		jb not_number		;Переход, если символ в al меньше 0
		cmp al, '9'			;Проверяем текущий символ, больше ли он 9
		ja not_number		;Переход, если символ в al больше 9
		inc esi				;Переходим к следующему символу
		jmp check_num_loop
	
	;Проверка на длину
	check_num_len:
		invoke lstrlen, ChekingSting
		cmp eax, 7
		ja not_len
	
	valid_number:
		xor eax, eax
		ret
	
	not_number:
		invoke MessageBox, hWin, addr pszSearchFrequencyErr, addr pszError, MB_ICONWARNING
		mov eax, 1
		ret
	
	not_len:
		invoke MessageBox, hWin, addr pszLenErr, addr pszError, MB_ICONWARNING
		mov eax, 1
		ret


CheckNumImput endp

GetSearchProc proc uses ebx edx ecx esi edi hWin:HWND
LOCAL SearchProc[512]:BYTE
	
	;Заполняем нулями
	invoke RtlZeroMemory, addr buffer, sizeof buffer
	invoke RtlZeroMemory, addr SearchProc, sizeof SearchProc
	
	;Получаем имя искомаого процесса в SearchProc
	invoke GetDlgItemText, hWin, IDC_EDT_GET_NAME_PROC, addr SearchProc, 512
	
	invoke StopSearchProc, hWin, addr SearchProc
	
	xor eax, eax
	ret 

GetSearchProc endp

StopSearchProc proc uses ebx edx ecx esi edi hWin:HWND, SearchProc:DWORD
LOCAL hSnap:HANDLE
LOCAL pe32:PROCESSENTRY32
LOCAL InversionDepth:WORD		;глубина рекурсии, для кол-во tab в выводе
LOCAL flag:WORD					;0-процесс не был найден, 1-процесс был найден
	
	;Создаем снимок всех процессов
	invoke CreateToolhelp32Snapshot,TH32CS_SNAPPROCESS, 0
	mov hSnap, eax
	
	;Инициализируем размер структуры
	mov pe32.dwSize, sizeof PROCESSENTRY32
	
	;Получаем первый процесс
	invoke Process32First, hSnap, addr pe32
	
	;Обнуляем флаг нахождения процесса
	mov flag, 0
	
	.while eax != FALSE
		;pe32.szExeFile - имя, pe32.th32ProcessID - pid
		;Вывод всех имен процессов в диалоговое окно
		;invoke lstrcat, addr buffer, addr pe32.szExeFile
		;invoke lstrcat, addr buffer, addr pszEnter
		;invoke SetDlgItemText, hWin, IDC_EDT_SEND_INFO_PROC, addr buffer
		
		;Сравниваем имена процессов
		invoke lstrcmp, SearchProc, addr pe32.szExeFile
		;Нашли искомый процесс
		.if eax==0
			mov flag, 1
			
			;Задержка перед запуском потока на сканирование ри первом обнаружении
			;Преобразовываем Ascii строку в число
			invoke atodw, addr DelayAfterDetection
			.if eax!=0
				invoke Sleep, eax
				;После обнуляем, чтобы это условие больше не отрабатывало
				invoke RtlZeroMemory, addr DelayAfterDetection, sizeof DelayAfterDetection
			.endif
			
			;Выводим его в диалоговое окно
			invoke wsprintf, addr StrProcID, addr formatPID, pe32.th32ProcessID		;переводим pid процесса из числа в строку
			invoke lstrcat, addr buffer, addr StrProcID								;добавляем его в буффер
			invoke lstrcat, addr buffer, addr pszTab								;ставим tab
			invoke lstrcat, addr buffer, addr pe32.szExeFile						;добавляем имя процесса
			invoke lstrcat, addr buffer, addr pszEnter								;делаем перевод строки
			invoke SetDlgItemText, hWin, IDC_EDT_SEND_INFO_PROC, addr buffer
			
			;Ищем дочерние процессы
			mov InversionDepth, 1
			invoke StopChildProc, hWin, pe32.th32ProcessID, InversionDepth
			
			;Замораживаем текущий процесс
			invoke FreezeProcess, pe32.th32ProcessID
			
			ret
			
		.endif 
		
		;Получаем следующий процесс
		invoke Process32Next, hSnap, addr pe32
	.endw
	
	;Закрываем дескриптор снимка
	invoke CloseHandle, hSnap
	
	;Процесс был найден
	exit_loop:
		.if flag==1
			xor eax,eax
			ret
		;Процесс не был найден
		.else
			mov eax,1
			ret
		.endif

StopSearchProc endp

StopChildProc proc uses ebx edx ecx esi edi hWin:HWND, SearchProcID:DWORD, InversionDepth:WORD
LOCAL pe32:PROCESSENTRY32
LOCAL hSnapshotChild:HANDLE
	
	;Увеличиваем глубину рекурсии на 1
	inc InversionDepth
	
	;Создаем снимок всех процессов
	invoke CreateToolhelp32Snapshot,TH32CS_SNAPPROCESS, 0
	mov hSnapshotChild, eax
	
	;Инициализируем размер структуры
	mov pe32.dwSize, sizeof PROCESSENTRY32
	
	;Получаем первый процесс
	invoke Process32First, hSnapshotChild, addr pe32
	
	.while eax != FALSE
	
		;Сравниваем PID-ы родительского процесса и PID поля родителя в дочернем
		mov ebx, SearchProcID
		mov edx, pe32.th32ParentProcessID
		cmp ebx, edx
		jne next_proc
		
		;Если нашли дочерний процесс, выводим его в диалоговое окно
		invoke wsprintf, addr StrProcID, addr formatPID, pe32.th32ProcessID		;переводим pid процесса из числа в строку
		invoke lstrcat, addr buffer, addr StrProcID								;добавляем его в буффер
		
		xor ebx, ebx									;выбрал ebx, так как lstrcat не трогает этот регистр
		mov bx, InversionDepth							;помещаем размер рекурсии, по нему будет прибавляться кол-во tab-ов
		.while bx !=0
			invoke lstrcat, addr buffer, addr pszTab	;добавляем tab
			dec ebx
		.endw
		
		invoke lstrcat, addr buffer, addr pe32.szExeFile						;добавляем имя процесса
		invoke lstrcat, addr buffer, addr pszEnter								;делаем перевод строки
		invoke SetDlgItemText, hWin, IDC_EDT_SEND_INFO_PROC, addr buffer
		
		;И ищем дочерние процессы у него
		invoke StopChildProc, hWin, pe32.th32ProcessID, InversionDepth
		
		;Замораживаем текущий процесс
		invoke FreezeProcess, pe32.th32ProcessID
			
		next_proc:
			;Получаем следующий процесс
			invoke Process32Next, hSnapshotChild, addr pe32
	.endw
	
	;Закрываем дескриптор снимка
	invoke CloseHandle, hSnapshotChild
	
	;Уменьшаем перед выходом глубину рекурсии на 1
	dec InversionDepth
	
	ret

StopChildProc endp

FreezeProcess proc uses ebx edx ecx esi edi TargetPID:DWORD
LOCAL hSnap:HANDLE
LOCAL tEntry:THREADENTRY32
LOCAL hThread:HANDLE

	;Создаем снимок всех процессов
	invoke CreateToolhelp32Snapshot,TH32CS_SNAPTHREAD, 0
	mov hSnap, eax
	
	;Инициализируем структуру THREADENTRY32
	mov tEntry.dwSize, sizeof THREADENTRY32
	
	;Получаем первый поток
	invoke Thread32First, hSnap, addr tEntry
	
	.while eax != FALSE
		; Проверяем принадлежность потока к нужному процессу
		mov eax, tEntry.th32OwnerProcessID 		
		cmp eax, TargetPID
		jne next_thread
		
		;Открываем поток с правами Suspend/Resume
		invoke OpenThread, THREAD_SUSPEND_RESUME, FALSE, tEntry.th32ThreadID
		mov hThread, eax
		
		xor eax, eax
		mov al, [flagThreadSearchProc]
		;Если флаг работы потока заморозки стоит в True
		.if al==1
			;Замораживаем поток
			invoke SuspendThread, hThread
		;Если флан работы потока заморозки стоит в False
		.elseif al==0
			;Запускаем процесс
			invoke ResumeThread, hThread
		.endif
				
		;Закрываем дескриптор потока
		invoke CloseHandle, hThread 
	
	next_thread:
		;Получаем следующий поток
		invoke Thread32Next, hSnap, addr tEntry
	
	.endw
	
	;Закрываем снипок потоков
	invoke CloseHandle, hSnap
	
	ret

FreezeProcess endp

end start
