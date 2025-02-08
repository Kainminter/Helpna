**HelpNa**

FFXI Windower Addon

**DISCLAIMER:**

This addon is a third-party tool designed for use with Final Fantasy XI. Use it at your own risk. 
The creator of this addon is not affiliated with Square Enix and is not responsible for any consequences arising from its use, including but not limited to violations of the game’s terms of service, account penalties, or unintended game behavior. 
By using this addon, you acknowledge and accept any potential risks involved.

**DESCRIPTION:**

The HelpNa addon lets your fellow party members ask the character who running the addon for spells. Stuff like protect, haste, paralyna, erase, etc.

This addon will scan for messages received in party chat.

If any party members say any of the known key words, the addon will cast the associated spell on that party member based on the keyword received.

If multiple requests are made, they are added to a queue. The addon will get to them eventually when the character is free. First in, first out.

It will attempt to wait until the character is not moving and is not performing any other actions until it casts a spell from the queue.


**INSTRUCTIONS:**

- In the windower console;

- lua l HelpNa  --  Loads the addon

- lua u HelpNa  --  Unloads the addon

- HelpNa add keyword Spell  -- This will add a new keyword / spell for it to recognize on the fly

- HelpNa remove keyword Spell -- This removes a keyword / spell from its list on the fly

- Once loaded, anyone in the party/alliance can ask the character for spells.
