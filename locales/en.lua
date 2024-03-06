local Translations = {
    error = {
        canceled = "Canceled ...",
        no_elec_veh = "This is not an electrician vehicle!",
        not_driver = "You must be the driver to do this!",
        not_worked = "You haven't done any jobs yet!",
    },
    main = {
        label = "Electrician HQ",
        park_in = "~g~[E]~w~ Store Vehicle",
        park_out = "~g~[E]~w~ Retrieve Vehicle",
        plate = "ELEC",
        job_start = "Your jobs have been added to your GPS - Go and complete your work.",
        repair = "~g~[E]~w~ Repair Electrical Fault",
        payslip = "~g~[E]~w~ Collect Payslip",
    },
    progress = {
        repair = "Repairs ...",
    },
    success = {
        repaired = "You've repaired the electrical fault. Head to the next job.",
        repaired_all = "You've finished all your jobs - Return your vehicle and collect your payslip.",
        payout = 'You were paid $ %{payment}!',
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})