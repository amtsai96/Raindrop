using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockManager : MonoBehaviour
{
    [Header("Rain Settings")]
    [Range(0.0f, 2.0f)]
    public float neighbourDistance;
    [Range(0.0f, 5.0f)]
    public float rotationSpeed;

    public GameObject RainPrefab;                    //公共變量
    public int numRain = 50;                          
    public GameObject[] allRain;                     //檢查器窗口更改魚的數量。然後創建一個allRain數組。當他們被實例化時，他們會去，也就是魚的數量將進入allRain數組
    public GameObject[] allTrail; 
    public Vector3 areaLimits = new Vector3(2.2f, 2.0f, 0);

    float startTime;
    // Vector3[] prepos = new Vector3[numRain];
    // Vector3[] prepos2 = new Vector3[numRain];
    void Start()
    {
        startTime = 0;
        allRain = new GameObject[numRain];
        // allTrail = new GameObject[numRain*2];
        for (int i = 0; i < numRain; i++)
        {
            Vector3 pos = new Vector3(this.transform.position.x + Random.Range(-areaLimits.x, areaLimits.x), -this.transform.position.y - Random.Range(-areaLimits.y, areaLimits.y), -3);
            GameObject newObj = (GameObject)Instantiate(RainPrefab, pos, Quaternion.identity);
            newObj.transform.localScale += new Vector3(Random.Range(-0.05f, 0.05f), Random.Range(-0.05f, 0.02f), 0);
            allRain[i] = newObj;
            allRain[i].GetComponent<Flock>().myManager = this;
            // Vector3 pos2[];
            // pos2 = [pos+new Vector3(0, 1, 0), pos+new Vector3(0, 4, 0)];
            // for(int j=0;j<2;j++){
            //     GameObject newTrail = (GameObject)Instantiate(RainPrefab, pos2[j], Quaternion.identity);
            //     newTrail.transform.localScale = new Vector3(newObj.transform.localScale.x/(2.2f+j*0.5f), newObj.transform.localScale.y/(2.2f+j*0.5f),newObj.transform.localScale.z);
            //     allTrail[i*2+j] = newObj;
            //     allTrail[i*2+j].GetComponent<Flock>().myManager = this;
            // }
        }

    }

    // Update is called once per frame
    void Update()
    {
        // if( (Time.time - StartTime)%100 == 40 ){
        //     for(int i=0;i<numRain;i++){
        //         prepos[i] = allRain[i].transform.position;
        //         allTrail[i*2 ]
        //     }
        // }

        // for(int i=0;i<numRain;i++){
        //     allTrail[i*2]
        // }

    }
}