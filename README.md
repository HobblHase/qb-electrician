# qb-electrician
Electrician Job for QBCore

A **only** QBCore script that was created by FaultyMatrix and jay-fivem. I edited the job restriction and created locals for all notifys, points, progressbars etc.

> If you want to add the blip for a "non"-Job, just comment line 78 and 80 in *cl/main.lua*!

**TO ADD THE ELECTRICIAN JOB**  
*add this to qb-core/shared/jobs.lua*
```lua
     ['electrician'] = {
		label = 'Electrician',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Electrician',
                payment = 60
            },
            ['1'] = {
                name = 'Engineer',
                payment = 65
            },
        },
	},
```

**DISCLAIMER**
* *I **did not** created that script! I only edited it so feel free to edit / fork it :)*
