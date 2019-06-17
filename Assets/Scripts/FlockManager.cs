using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlockManager : MonoBehaviour
{
    [Header("Raindrop Settings")]
    [Range(0.0f, 5.0f)]
    public float minSpeed;
    [Range(0.0f, 5.0f)]
    public float maxSpeed;
    [Range(1.0f, 2.0f)]
    public float neighbourDistance;
    [Range(0.0f, 5.0f)]
    public float rotationSpeed;
    [Range(70, 120)]
    public int num;

    public GameObject rainPrefab;                    //公共變量
    // public GameObject rainPrefab_02;
    // public GameObject rainPrefab_03;
    public GameObject[] allRain;                     //檢查器窗口更改魚的數量。然後創建一個allFish數組。當他們被實例化時，他們會去，也就是魚的數量將進入allFish數組
    public Vector3 areaLimits = new Vector3(4, 10, 0);

    // Use this for initialization
    void Start()
    {
        allRain = new GameObject[num*3];
        for (int i = 0; i < allRain.Length; i+=3)
        {
            Vector3 pos = new Vector3(this.transform.position.x + Random.Range(-areaLimits.x, areaLimits.x), -this.transform.position.y - Random.Range(-areaLimits.y, areaLimits.y), -3);
            for(int j=0;j<3;j++){
                allRain[i+j] = (GameObject)Instantiate(rainPrefab.transform.GetChild(j).gameObject, pos, Quaternion.identity);
                allRain[i+j].GetComponent<Flock>().myManager = this;
                pos += new Vector3(0, 0.15f, 0);
            }
            
        }

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}