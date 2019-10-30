using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

public class ScoreAnim : MonoBehaviour
{
    public string testNum;
    public float fontSpacing = 70;
    public Text ModelTxt;
    public float DGTime;
    public float DGHeight;
    List<Text> numList;
    char[] ns;
    
    //初始化
    public void init(string initNum)
    {
        numList = new List<Text>();
        testNum = initNum;
        ComboPlayingState(false);
    }

    public void ChangeColor(Color color)
    {
        for (int i = 0; i < numList.Count; i++)
        {
            numList[i].color = color;
        }
    }
    
    //更改实时数据
    public void ChangeNum(string GiveNum)
    {
        
        testNum = GiveNum;
      
        ComboPlayingState(true);
    }

    public void ComboPlayingState(bool isJump)
    {
        ns = testNum.ToCharArray();
        if (transform.childCount < ns.Length)
        {
            int count = ns.Length - transform.childCount;
            for (int i = 0; i < count; i++)
            {
                GameObject obj = GameObject.Instantiate(ModelTxt.gameObject);
                obj.SetActive(false);
                obj.transform.SetParent(this.transform);
                obj.transform.localPosition = Vector3.zero;
                obj.transform.localScale = Vector3.one;
                obj.transform.localEulerAngles = Vector3.zero;
                obj.GetComponent<Text>().text = string.Empty;
                numList.Add(obj.GetComponent<Text>());
            }
        }
        
        for (int j = 0; j < ns.Length; j++)
        {
            if (j < numList.Count)
            {
                numList[j].gameObject.SetActive(true);
            }
        }
        if (numList.Count >= ns.Length)
        {
            for (int k = 0; k < numList.Count - ns.Length; k++)
            {
                numList[numList.Count - 1 - k].gameObject.SetActive(false);
            }
        }
        
        if (ns.Length % 2 == 0)
        {
            for (int i = 0; i < ns.Length; i++)
            {
                if (i < numList.Count)
                {
                    numList[i].transform.localPosition = new Vector3(((ns.Length - 1) / 2 - i) * fontSpacing + fontSpacing / 2, numList[i].transform.localPosition.y, 0);
                    if (numList[i].text != ns[ns.Length - 1 - i].ToString() && isJump)
                    {
                        numList[i].transform.DORestart();
                        numList[i].transform.localPosition = new Vector3(numList[i].transform.localPosition.x, DGHeight, 0);
                        numList[i].transform.DOLocalMoveY(0, DGTime);
                    }
                }
            }
        }
        else
        {
            for (int i = 0; i < ns.Length; i++)
            {

                if (i < numList.Count)
                {
                    numList[i].transform.localPosition = new Vector3(((ns.Length - 1) / 2 - i) * fontSpacing, numList[i].transform.localPosition.y, 0);
                    if (numList[i].text != ns[ns.Length - 1 - i].ToString() && isJump)
                    {
                        numList[i].transform.DORestart();
                        numList[i].transform.localPosition = new Vector3(numList[i].transform.localPosition.x, DGHeight, 0);
                        numList[i].transform.DOLocalMoveY(0, DGTime);
                    }
                }
            }
        }
        for (int j = 0; j < ns.Length; j++)
        {
            if (j < numList.Count)
            {
                numList[j].gameObject.SetActive(true);
                numList[j].text = ns[ns.Length - 1 - j].ToString();
            }
        }
    }
}
