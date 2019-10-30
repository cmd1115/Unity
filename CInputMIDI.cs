using System;
using System.Collections.Generic;
using UnityEngine;

public class CInputMIDI : IInputDevice
{
    public uint hMidiIn;

    public List<STInputEvent> listEventBuffer;

    public CInputMIDI(int nID)
    {
        hMidiIn = 0;
        listEventBuffer = new List<STInputEvent>(32);
        listInputEvents = new List<STInputEvent>(32);
        eInputDeviceType = EInputDevice.MIDIIn;
        GUID = "";
        ID = nID;
    }

    public void MIDISignalFromMessage(uint wMsg, int dwInstance, int dwParam1, int dwParam2, long nSystemTime) 
    {
        if (wMsg == CWin32.MIM_DATA)
        {
            int nMIDIevent = dwParam1 & 0xF0;
            int nPara1 = (dwParam1 >> 8) & 0xFF;
            int nPara2 = (dwParam1 >> 16) & 0xFF;

            if ((nMIDIevent == 0x90) && (nPara2 != 0))
            {
                STInputEvent item = new STInputEvent
                {
                    KeyCode = nPara1,
                    IsDown = true,
                    TimeStamp = nSystemTime,
                    Velocity = nPara2
                };

                this.listEventBuffer.Add(item);
            }
        }
    }

    public override void Update()
    {
        for (int i = 0; i < this.listEventBuffer.Count; i++)
            this.listInputEvents.Add(this.listEventBuffer[i]);

        this.listEventBuffer.Clear();
    }

    public override void OnGUI()
    {
    }

    public override void Dispose()
    {
        if (this.listEventBuffer != null)
        {
            this.listEventBuffer = null;
        }
        if (this.listInputEvents != null)
        {
            this.listInputEvents = null;
        }
        CWin32.midiInStop(hMidiIn);
        CWin32.midiInReset(hMidiIn);
        CWin32.midiInClose(hMidiIn);
        Debug.Log(string.Format("MIDI：{0} 已停止", hMidiIn));
    }
}
