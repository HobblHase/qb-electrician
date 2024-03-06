local Translations = {
    error = {
        canceled = "Abgebrochen ...",
        no_elec_veh = "Dies ist kein Elektriker-Fahrzeug!",
        not_driver = "Du musst der Fahrzeugführer sein um dies zu tun!",
        not_worked = "Du hast noch keine Arbeit geleistet!",
    },
    main = {
        label = "Elektriker HQ",
        park_in = "~g~[E]~w~ Fahrzeug einparken",
        park_out = "~g~[E]~w~ Fahrzeug ausparken",
        plate = "ELEC",
        job_start = "Deine Arbeiten wurden auf deinem GPS makiert - Gehe und vollende deine Arbeit!",
        repair = "~g~[E]~w~ Repariere Defekt",
        payslip = "~g~[E]~w~ Bezahlung abholen",
    },
    progress = {
        repair = "Repariert ...",
    },
    success = {
        repaired = "Du hast den elektrischen Fehler behoben. Auf zum nächsten Auftrag.",
        repaired_all = "Du hast alle deine Aufträge erledigt - Gebe dein Fahrzeug zurück und holen dir deine Bezahlung ab.",
        payout = 'Du wirst mit $ %{payment} für deine Arbeit bezahlt!',
    },
}

if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end