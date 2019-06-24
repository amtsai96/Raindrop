using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flock : MonoBehaviour
{

    public FlockManager myManager;
    float speed;
    void Start()
    {
        speed = Random.Range(1.0f,5.0f);
    }

    void Update()
    {
        float t = Time.time;
        float x = (Random.Range(0.03f, 0.08f) - .005f) * .8f;//sin(3 * w)*pow(sin(w), 6)*.45;
        //float w = transform.position.y * 0.2f;
        x -= Mathf.Sin(1.01f*x) * .8f;
        float y = -Mathf.Sin(t) - Mathf.Sin(t + Mathf.Sin(t+ Mathf.Sin(1.03f*t + 6.1234f)) * .5f) * .25f + 6.1234f;
        transform.Translate(x, -Random.Range(0.001f, 0.008f) * Mathf.Abs(transform.position.y - y) * Mathf.Pow(2, 10*(transform.localScale.x - 0.12f)), 0);

        if (transform.position.y < -3)
        {
            transform.position = new Vector3(Random.Range(-4.0f, 4.0f), 2.4f + Random.Range(0f, 8.0f), -3);
            transform.localScale = new Vector3(0.12f, 0.15f, 0.1f);
            transform.localScale += new Vector3(Random.Range(-0.05f, 0.02f), Random.Range(-0.05f, 0.02f), 0);
        }
        
        ApplyRules();

    }
    void ApplyRules()
    {
        GameObject[] gos;
        gos = myManager.allRain;

        Vector3 vcentre = Vector3.zero;
        Vector3 vavoid = Vector3.zero;
        float gSpeed = 0.01f;
        float nDistance;
        int groupSize = 0;

        foreach (GameObject go in gos)
        {
            if (go != this.gameObject)
            {
                nDistance = Vector3.Distance(go.transform.position, this.transform.position);
                if (nDistance <= myManager.neighbourDistance)
                {
                    vcentre += go.transform.position;
                    groupSize++;
                    if (nDistance < 0.08f*( 1 + transform.localScale.x))
                    {
                        if (transform.localScale.x > go.transform.localScale.x)
                        {
                            go.transform.position = new Vector3(Random.Range(-4.0f, 4.0f), 2.4f + Random.Range(0f, 8.0f), -3);
                            go.transform.localScale = new Vector3(0.12f, 0.15f, 0.1f);
                            transform.localScale += new Vector3((1+3*(Mathf.Abs(go.transform.localScale.x - 0.1f)))*0.01f, (1+3*(Mathf.Abs(go.transform.localScale.y - 0.1f)))*0.03f, 0);
                        }
                        else {
                            transform.position = new Vector3(Random.Range(-4.0f, 4.0f), 2.4f + Random.Range(0f, 8.0f), -3);
                            transform.localScale = new Vector3(0.12f, 0.15f, 0.1f);
                            go.transform.localScale += new Vector3((1+3*(Mathf.Abs(transform.localScale.x - 0.1f)))*0.01f, (1+3*(Mathf.Abs(transform.localScale.y - 0.1f)))*0.03f, 0);
                        }
                    }

                    Flock anotherFlock = go.GetComponent<Flock>();
                    gSpeed = gSpeed + anotherFlock.speed;
                }
            }
        }

        if (groupSize > 0)
        {
            vcentre = vcentre / groupSize;
            speed = gSpeed / groupSize;

            Vector3 direction = vcentre - transform.position;
            if (direction != Vector3.zero)
                transform.rotation = Quaternion.Slerp(transform.rotation,
                                                      Quaternion.LookRotation(direction),
                                                      myManager.rotationSpeed * Time.deltaTime);
            transform.localRotation = Quaternion.Euler(transform.rotation.x, transform.rotation.y, 0);
            transform.position = new Vector3(transform.position.x, transform.position.y, -3);
        }
    }
}