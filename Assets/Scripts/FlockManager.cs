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
    public int numRain;                         // 
    public GameObject[] allRain;                     //檢查器窗口更改魚的數量。然後創建一個allRain數組。當他們被實例化時，他們會去，也就是魚的數量將進入allRain數組
    public Vector3 swimLimits = new Vector3(2.2f, 2.5f, 0);

    // Use this for initialization
    void Start()
    {
        allRain = new GameObject[numRain];
        for (int i = 0; i < numRain; i++)
        {
            Vector3 pos = new Vector3(this.transform.position.x + Random.Range(-swimLimits.x, swimLimits.x), -this.transform.position.y - Random.Range(-swimLimits.y, swimLimits.y), -3);/*new Vector3(Random.Range(-swimLimits.x, swimLimits.x),
                                                                  Random.Range(-swimLimits.y, swimLimits.y),
                                                                  Random.Range(-swimLimits.z, swimLimits.z));*/
            allRain[i] = (GameObject)Instantiate(RainPrefab, pos, Quaternion.identity);
            allRain[i].GetComponent<Flock>().myManager = this;
        }

    }

    // Update is called once per frame
    void Update()
    {

    }
}