Enable_type_text_to_accept= false
Enable_Only_1_language= false
Default_language_number= 1

--Version 3
--default languages: english=1, spanish=2, france=3,germany=4
-- Add "," between the rules

arok_text={
	{
		"English",
		"Continue",
		"Yes!",
		"No",
		"Do you accept the server rules?",
		"i agree to the rules",
		"Type this in the textbox: ",
		"Type the key to play, then press Continue",
		"You have to agree the rules to play on this server. You are welcome back next time",
		"You have now the permission to play!",
		"Everyone, please welcome",
		"to the server!",
		"Server Rules ,No ask for privs or admin stuff ,No swearing or bad names ,No hacking if you hack you will be baned for ever ,No cheating or useing of bugs! ,Don't mess up with moderators or admins ,Only Lejo is Admin! ,No Crossteaming!,no spaming!",
		"Cancel",
		"Welcome",
		"type /rules to see this again",
	},
	{
		"Espanol",
		"Continuar",
		"Si!",
		"No",
		"Se aceptan las reglas del servidor?",
		"estoy de acuerdo con las reglas",
		"Escriba lo siguiente en el cuadro de texto: ",
		"Escriba la clave que desempenar, a continuacion, pulse Continuar",
		"Tendra que aceptar las reglas para jugar a este servidor. Eres bienvenido de nuevo a la proxima vez",
		" Usted no tiene permiso para jugar!",
		"Todo el mundo, por favor espera",
		"al servidor!",
		"Reglas del servidor, no piden privs o cosas por el administrador, no jurar o malos nombres, n piratería si se le baned para siempre, No se metan con moderadores o administradores, Lejo Sólo es admin!, ¡Sin Crossteaming!, correo no deseado",
		"Cancelar",
		"Bienvenido",
		"escriba para /rules ver esto de nuevo",
	},
	{
		"francais",
		"Continuer",
		"Oui!",
		"Non",
		"Acceptez-vous les regles du serveur?",
		"je suis daccord sur les regles",
		"Taper dans la zone de texte: ",
		"Tapez la cle a jouer, puis appuyez sur Continuer",
		"Vous devez accepter les regles pour jouer a ce serveur. Vous etes les bienvenus dans la prochaine fois",
		"Vous ne lavez pas la permission de jouer!",
		"Jokainen, ota tervetulleita",
		"palvelimelle!",
		"Règles de serveur, No demandent privs ou admin stuff, Aucune prestation de serment ou de mauvais noms, Pas de piratage si vous vous baned à jamais, ne plaisante pas avec les modérateurs et admins, Seulement Lejo est admin!, Pas de Crossteaming!, pas de spam",
		"Annuler",
		"Bienvenue",
		"Type /rules pour voir ce message",
	},
	{
		"Deutsch",
		"Fortsetzen",
		"Ja!",
		"Nein",
		"Akzeptieren Sie die Server-Regeln?",
		"ich stimme den regeln",
		"Geben Sie dies in das Textfeld ein: ",
		"Geben Sie den Schlussel zu spielen, drucken Sie weiter",
		"Sie mussen die Regeln akzeptieren um auf diesem Server spielen zu können. Sie sind nächste Mal wieder Willkommen",
		"Sie haben eine Berechtigung zu spielen!",
		"Jeder, bitte begruBen",
		"an den Server!",
		"Server-Regeln, fragen Sie nicht nach privs oder Admin-Zeug, kein Fluchen oder schlechte Namen, kein Hacken, wenn Sie hacken werden sie für immer gebannt, Verwirren Sie nicht mit Moderatoren oder Administratoren auf, Nur Lejo ist Admin!, Teame nicht über deine Teamgrenzen hinaus!, kein spam",
		"Stornieren",
		"Herzlich willkommen",
		"Gebe /rules ein um dies wieder zu sehen",
	},
}
agreerules_form=""
function create_agreerules_form(i)
	local form="size[8,9;] "
	local aot="," .. arok_text[i][7]
	local doacc="," .. arok_text[i][5]
	if Enable_type_text_to_accept==true then
		aot=aot ..",".. arok_text[i][6]
		doacc=""
	else aot="" end
	form=form.."textlist[-0.1,-0.1;8,9;rules;" .. arok_text[i][13] .. ", " .. arok_text[i][16].. "," .. aot .. doacc .. "]"
	if Enable_type_text_to_accept==true then
	form=form.." field[0.5,7;7.5,2;text;" .. arok_text[i][8]..";]"
	form=form.." button_exit[2,7.5;2,2;yes;" .. arok_text[i][2].. "]"
	form=form.." button[4,7.5;2,2;no;" .. arok_text[i][14] .. "]"
	else
	form=form.." button_exit[2,7.5;2,2;yes;" .. arok_text[i][3] .. "]"
	form=form.." button[4,7.5;2,2;no;".. arok_text[i][4] .."]"
	end
	form=form.." field[0,0;0,0;lang;;" .. i .."]"
	if Enable_Only_1_language==false then
		local cpos=0
		for ii = 1, #arok_text, 1 do
			form=form.." button_exit[" ..cpos ..",5.3;2,2;lang" .. (ii) .. ";" .. arok_text[ii][1] .. "]"
			cpos=cpos+2
		end
	end
	agreerules_form=form
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form== "AgreeRulesYesNoForm" then
		local name=player:get_player_name()
		local privs = minetest.get_player_privs(name)
		local i=tonumber(pressed.lang)
		if i==nil then
			i=Default_language_number
		end

		if pressed.lang1 or pressed.lang2 or pressed.lang3 or pressed.lang4 then
			local n=1
			if pressed.lang2 then n=2 end
			if pressed.lang3 then n=3 end
			if pressed.lang4 then n=4 end
			minetest.after((0.1), function(n)
				create_agreerules_form(n)
				return minetest.show_formspec(name, "AgreeRulesYesNoForm",agreerules_form)
			end, n)
			return true
		end


		if pressed.rules then
			minetest.after((0.1), function(i)
				create_agreerules_form(i)
				return minetest.show_formspec(name, "AgreeRulesYesNoForm",agreerules_form)
			end, i)
			return true
		end


		if ((not pressed.yes) or pressed.no) then
			minetest.after((0.1), function(i)
				create_agreerules_form(i)
				return minetest.show_formspec(name, "AgreeRulesYesNoForm",agreerules_form)
			end, i)
			return true
		end

		if Enable_type_text_to_accept==true then
			if pressed.text~=arok_text[i][6] then
			minetest.after((0.1), function(i)
				create_agreerules_form(i)
				return minetest.show_formspec(name, "AgreeRulesYesNoForm",agreerules_form)
			end, i)
			return true
			end
		end

--================= Privs to grant =================
			privs.shout = true
			privs.zoom = true
--===========================================

			minetest.set_player_privs(name, privs)
			minetest.chat_send_player(name,arok_text[i][15] .." "..name.. " " .. arok_text[i][10])
			minetest.after(0.1, function()
				minetest.show_formspec(name, "main:info", main.get_help_form("general"))
			end)
	end
end)

minetest.register_on_joinplayer(function(player)
	if minetest.check_player_privs(player:get_player_name(), {shout=true})==false then
		create_agreerules_form(Default_language_number)
		minetest.show_formspec(player:get_player_name(), "AgreeRulesYesNoForm",agreerules_form)
	end
end)

minetest.register_chatcommand("rules", {
	params = "",
	description = "Rules",
	func = function(name, param)
	create_agreerules_form(Default_language_number)
	minetest.after((0.1), function()
		return minetest.show_formspec(name, "AgreeRulesYesNoForm",agreerules_form)
	end)
end})

--  Add sfinv page.
sfinv.register_page("agreerules:rules", {
	title = "Rules",
	get = function(self, player, context)
	create_agreerules_form(Default_language_number)
		return sfinv.make_formspec(player, context, agreerules_form, false)
	end
})
