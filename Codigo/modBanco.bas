Attribute VB_Name = "modBanco"
Option Explicit

'MODULO PROGRAMADO POR NEB
'Kevin Birmingham
'kbneb@hotmail.com

Sub IniciarDeposito(ByVal UserIndex As Integer)
On Error GoTo errhandler

'Hacemos un Update del inventario del usuario
Call UpdateBanUserInv(True, UserIndex, 0)
'Atcualizamos el dinero
Call SendUserStatsBox(UserIndex)
'Mostramos la ventana pa' comerciar y ver ladear la osamenta. jajaja
Call WriteBankInit(UserIndex)
UserList(UserIndex).flags.Comerciando = True

errhandler:

End Sub

Sub SendBanObj(UserIndex As Integer, Slot As Byte, Object As UserOBJ)

UserList(UserIndex).BancoInvent.Object(Slot) = Object

If Object.ObjIndex > 0 Then
    Call WriteChangeBankSlot(UserIndex, Slot)
Else
    Call WriteChangeBankSlot(UserIndex, Slot)
End If

End Sub

Sub UpdateBanUserInv(ByVal UpdateAll As Boolean, ByVal UserIndex As Integer, ByVal Slot As Byte)

Dim NullObj As UserOBJ
Dim LoopC As Byte

'Actualiza un solo slot
If Not UpdateAll Then

    'Actualiza el inventario
    If UserList(UserIndex).BancoInvent.Object(Slot).ObjIndex > 0 Then
        Call SendBanObj(UserIndex, Slot, UserList(UserIndex).BancoInvent.Object(Slot))
    Else
        Call SendBanObj(UserIndex, Slot, NullObj)
    End If

Else

'Actualiza todos los slots
    For LoopC = 1 To MAX_BANCOINVENTORY_SLOTS

        'Actualiza el inventario
        If UserList(UserIndex).BancoInvent.Object(LoopC).ObjIndex > 0 Then
            Call SendBanObj(UserIndex, LoopC, UserList(UserIndex).BancoInvent.Object(LoopC))
        Else
            
            Call SendBanObj(UserIndex, LoopC, NullObj)
            
        End If

    Next LoopC

End If

End Sub

Sub UserRetiraItem(ByVal UserIndex As Integer, ByVal i As Integer, ByVal Cantidad As Integer)
On Error GoTo errhandler


If Cantidad < 1 Then Exit Sub


Call SendUserStatsBox(UserIndex)

   
       If UserList(UserIndex).BancoInvent.Object(i).amount > 0 Then
            If Cantidad > UserList(UserIndex).BancoInvent.Object(i).amount Then Cantidad = UserList(UserIndex).BancoInvent.Object(i).amount
            'Agregamos el obj que compro al inventario
            Call UserReciveObj(UserIndex, CInt(i), Cantidad)
            'Actualizamos el inventario del usuario
            Call UpdateUserInv(True, UserIndex, 0)
            'Actualizamos el banco
            Call UpdateBanUserInv(True, UserIndex, 0)
            'Actualizamos la ventana de comercio
            Call UpdateVentanaBanco(UserIndex)
       End If



errhandler:

End Sub

Sub UserReciveObj(ByVal UserIndex As Integer, ByVal ObjIndex As Integer, ByVal Cantidad As Integer)

Dim Slot As Integer
Dim obji As Integer


If UserList(UserIndex).BancoInvent.Object(ObjIndex).amount <= 0 Then Exit Sub

obji = UserList(UserIndex).BancoInvent.Object(ObjIndex).ObjIndex


'�Ya tiene un objeto de este tipo?
Slot = 1
Do Until UserList(UserIndex).Invent.Object(Slot).ObjIndex = obji And _
   UserList(UserIndex).Invent.Object(Slot).amount + Cantidad <= MAX_INVENTORY_OBJS
    
    Slot = Slot + 1
    If Slot > MAX_INVENTORY_SLOTS Then
        Exit Do
    End If
Loop

'Sino se fija por un slot vacio
If Slot > MAX_INVENTORY_SLOTS Then
        Slot = 1
        Do Until UserList(UserIndex).Invent.Object(Slot).ObjIndex = 0
            Slot = Slot + 1

            If Slot > MAX_INVENTORY_SLOTS Then
                Call WriteConsoleMsg(UserIndex, "No pod�s tener mas objetos.", FontTypeNames.FONTTYPE_INFO)
                Exit Sub
            End If
        Loop
        UserList(UserIndex).Invent.NroItems = UserList(UserIndex).Invent.NroItems + 1
End If



'Mete el obj en el slot
If UserList(UserIndex).Invent.Object(Slot).amount + Cantidad <= MAX_INVENTORY_OBJS Then
    
    'Menor que MAX_INV_OBJS
    UserList(UserIndex).Invent.Object(Slot).ObjIndex = obji
    UserList(UserIndex).Invent.Object(Slot).amount = UserList(UserIndex).Invent.Object(Slot).amount + Cantidad
    
    Call QuitarBancoInvItem(UserIndex, CByte(ObjIndex), Cantidad)
Else
    Call WriteConsoleMsg(UserIndex, "No pod�s tener mas objetos.", FontTypeNames.FONTTYPE_INFO)
End If


End Sub

Sub QuitarBancoInvItem(ByVal UserIndex As Integer, ByVal Slot As Byte, ByVal Cantidad As Integer)



Dim ObjIndex As Integer
ObjIndex = UserList(UserIndex).BancoInvent.Object(Slot).ObjIndex

    'Quita un Obj

       UserList(UserIndex).BancoInvent.Object(Slot).amount = UserList(UserIndex).BancoInvent.Object(Slot).amount - Cantidad
        
        If UserList(UserIndex).BancoInvent.Object(Slot).amount <= 0 Then
            UserList(UserIndex).BancoInvent.NroItems = UserList(UserIndex).BancoInvent.NroItems - 1
            UserList(UserIndex).BancoInvent.Object(Slot).ObjIndex = 0
            UserList(UserIndex).BancoInvent.Object(Slot).amount = 0
        End If

    
    
End Sub

Sub UpdateVentanaBanco(ByVal UserIndex As Integer)
    Call WriteBankOK(UserIndex)
End Sub

Sub UserDepositaItem(ByVal UserIndex As Integer, ByVal Item As Integer, ByVal Cantidad As Integer)

On Error GoTo errhandler

'El usuario deposita un item
Call SendUserStatsBox(UserIndex)
   
If UserList(UserIndex).Invent.Object(Item).amount > 0 And UserList(UserIndex).Invent.Object(Item).Equipped = 0 Then
            
            If Cantidad > 0 And Cantidad > UserList(UserIndex).Invent.Object(Item).amount Then Cantidad = UserList(UserIndex).Invent.Object(Item).amount
            'Agregamos el obj que compro al inventario
            Call UserDejaObj(UserIndex, CInt(Item), Cantidad)
            'Actualizamos el inventario del usuario
            Call UpdateUserInv(True, UserIndex, 0)
            'Actualizamos el inventario del banco
            Call UpdateBanUserInv(True, UserIndex, 0)
            'Actualizamos la ventana del banco
            
            Call UpdateVentanaBanco(UserIndex)
            
End If

errhandler:

End Sub

Sub UserDejaObj(ByVal UserIndex As Integer, ByVal ObjIndex As Integer, ByVal Cantidad As Integer)

Dim Slot As Integer
Dim obji As Integer

If Cantidad < 1 Then Exit Sub

obji = UserList(UserIndex).Invent.Object(ObjIndex).ObjIndex

'�Ya tiene un objeto de este tipo?
Slot = 1
Do Until UserList(UserIndex).BancoInvent.Object(Slot).ObjIndex = obji And _
         UserList(UserIndex).BancoInvent.Object(Slot).amount + Cantidad <= MAX_INVENTORY_OBJS
            Slot = Slot + 1
        
            If Slot > MAX_BANCOINVENTORY_SLOTS Then
                Exit Do
            End If
Loop

'Sino se fija por un slot vacio antes del slot devuelto
If Slot > MAX_BANCOINVENTORY_SLOTS Then
        Slot = 1
        Do Until UserList(UserIndex).BancoInvent.Object(Slot).ObjIndex = 0
            Slot = Slot + 1

            If Slot > MAX_BANCOINVENTORY_SLOTS Then
                Call WriteConsoleMsg(UserIndex, "No tienes mas espacio en el banco!!", FontTypeNames.FONTTYPE_INFO)
                Exit Sub
                Exit Do
            End If
        Loop
        If Slot <= MAX_BANCOINVENTORY_SLOTS Then UserList(UserIndex).BancoInvent.NroItems = UserList(UserIndex).BancoInvent.NroItems + 1
        
        
End If

If Slot <= MAX_BANCOINVENTORY_SLOTS Then 'Slot valido
    'Mete el obj en el slot
    If UserList(UserIndex).BancoInvent.Object(Slot).amount + Cantidad <= MAX_INVENTORY_OBJS Then
        
        'Menor que MAX_INV_OBJS
        UserList(UserIndex).BancoInvent.Object(Slot).ObjIndex = obji
        UserList(UserIndex).BancoInvent.Object(Slot).amount = UserList(UserIndex).BancoInvent.Object(Slot).amount + Cantidad
        
        Call QuitarUserInvItem(UserIndex, CByte(ObjIndex), Cantidad)

    Else
        Call WriteConsoleMsg(UserIndex, "El banco no puede cargar tantos objetos.", FontTypeNames.FONTTYPE_INFO)
    End If

Else
    Call QuitarUserInvItem(UserIndex, CByte(ObjIndex), Cantidad)
End If

End Sub

Sub SendUserBovedaTxt(ByVal sendIndex As Integer, ByVal UserIndex As Integer)
On Error Resume Next
Dim j As Integer

Call WriteConsoleMsg(sendIndex, UserList(UserIndex).name, FontTypeNames.FONTTYPE_INFO)
Call WriteConsoleMsg(sendIndex, " Tiene " & UserList(UserIndex).BancoInvent.NroItems & " objetos.", FontTypeNames.FONTTYPE_INFO)

For j = 1 To MAX_BANCOINVENTORY_SLOTS
    If UserList(UserIndex).BancoInvent.Object(j).ObjIndex > 0 Then
        Call WriteConsoleMsg(sendIndex, " Objeto " & j & " " & ObjData(UserList(UserIndex).BancoInvent.Object(j).ObjIndex).name & " Cantidad:" & UserList(UserIndex).BancoInvent.Object(j).amount, FontTypeNames.FONTTYPE_INFO)
    End If
Next

End Sub

Sub SendUserBovedaTxtFromChar(ByVal sendIndex As Integer, ByVal charName As String)
On Error Resume Next
Dim j As Integer
Dim CharFile As String, Tmp As String
Dim ObjInd As Long, ObjCant As Long

CharFile = CharPath & charName & ".chr"

If FileExist(CharFile, vbNormal) Then
    Call WriteConsoleMsg(sendIndex, charName, FontTypeNames.FONTTYPE_INFO)
    Call WriteConsoleMsg(sendIndex, " Tiene " & GetVar(CharFile, "BancoInventory", "CantidadItems") & " objetos.", FontTypeNames.FONTTYPE_INFO)
    For j = 1 To MAX_BANCOINVENTORY_SLOTS
        Tmp = GetVar(CharFile, "BancoInventory", "Obj" & j)
        ObjInd = ReadField(1, Tmp, Asc("-"))
        ObjCant = ReadField(2, Tmp, Asc("-"))
        If ObjInd > 0 Then
            Call WriteConsoleMsg(sendIndex, " Objeto " & j & " " & ObjData(ObjInd).name & " Cantidad:" & ObjCant, FontTypeNames.FONTTYPE_INFO)
        End If
    Next
Else
    Call WriteConsoleMsg(sendIndex, "Usuario inexistente: " & charName, FontTypeNames.FONTTYPE_INFO)
End If

End Sub

